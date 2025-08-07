import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/profils/userPreference/CategoryItem.dart';
import 'package:odc_mobile_template/pages/profils/userPreference/userPreferenceController.dart';
import '../../../business/models/category/category.dart';

class UserPreferencesPage extends ConsumerStatefulWidget {
  const UserPreferencesPage({super.key});

  @override
  ConsumerState<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends ConsumerState<UserPreferencesPage> {
  final List<Category> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    // Charge les catégories si elles ne sont pas déjà chargées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(userPreferenceControllerProvider);
      if (state.categories == null) {
        ref.read(userPreferenceControllerProvider.notifier).getCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userPreferenceControllerProvider);
    final categories = state.categories;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 255, 255, 255),
        title: const Text('Préférences de catégories'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.orange,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            color: Colors.orange,
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez vos centres d\'intérêt',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nous utiliserons ces informations pour personnaliser votre expérience',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Champ de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher des catégories...',
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                // TODO: Implémenter la recherche
              },
            ),
            const SizedBox(height: 24),

            // Catégories sélectionnées
            if (_selectedCategories.isNotEmpty) ...[
              Text(
                'Vos sélections (${_selectedCategories.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedCategories.map((category) {
                  return Chip(
                    label: Text(category.name!),
                    backgroundColor: Colors.orange[50],
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _toggleCategory(category),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Affichage conditionnel selon l'état
            if (state.isLoading && categories == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMsg != null)
              Expanded(
                child: Center(child: Text('Erreur: ${state.errorMsg}')),
              )
            else if (categories == null || categories.isEmpty)
                const Expanded(
                  child: Center(child: Text('Aucune catégorie disponible')),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.read(userPreferenceControllerProvider.notifier).getCategories(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: categories.map((category) {
                          final isSelected = _selectedCategories.any((c) => c.id == category.id);
                          return CategoryItem(
                            category: category.name!,
                            isSelected: isSelected,
                            onTap: () => _toggleCategory(category),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(Category category) {
    setState(() {
      if (_selectedCategories.any((c) => c.id == category.id)) {
        _selectedCategories.removeWhere((c) => c.id == category.id);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _savePreferences() async {
    final categoryIds = _selectedCategories.map((c) => c.id).toList();
    if (categoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une catégorie'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = ref.read(LoginCtrlProvider).user;
    if (user?.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous reconnecter'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // Active le mode flottant
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
        ),
      );
      return;
    }

    final loadingSnackBar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom:
          MediaQuery.of(context).size.height *
              0.1, // Position au-dessus du BottomNavBar
          left: 20,
          right: 20,
        ),
        content: const Row(
          children: [
            CircularProgressIndicator(color: Colors.orange,),
            SizedBox(width: 20),
            Text('Enregistrement en cours...'),

          ],
        ),
        duration: const Duration(minutes: 1), // Longue durée pour éviter la disparition prématurée
      ),
    );

    try {
      final controller = ref.read(userPreferenceControllerProvider.notifier);
      final success = await controller.savePreference(categoryIds, user!.token!);

      loadingSnackBar.close();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedCategories.length} préférences sauvegardées'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom:
              MediaQuery.of(context).size.height *
                  0.1, // Position au-dessus du BottomNavBar
              left: 20,
              right: 20,
            ),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de l\'enregistrement'),
            backgroundColor: Colors.red,

          ),
        );
      }
    } catch (e) {
      loadingSnackBar.close();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}