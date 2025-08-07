import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odc_mobile_template/pages/profils/editProfile/editProfileController.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import '../../../main.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final NavigationUtils navigation = getIt.get<NavigationUtils>();
  final ImagePicker _picker = ImagePicker();

  XFile? _profileImage;

  // Contrôleurs pour les champs de texte
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _professionController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec des valeurs vides
    _fullNameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _professionController = TextEditingController();
    _addressController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editControllerProvider.notifier).loadProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Mettre à jour les contrôleurs lorsque le state change
    final state = ref.read(editControllerProvider);
    print("Le profile ${state.profile}");
    if (state.profile != null) {
      final profile = state.profile!;
      if (profile.user?.name != null) _fullNameController.text = profile.user!.name!;
      if (profile.bio != null) _bioController.text = profile.bio!;
      if (profile.telephone != null) _phoneNumberController.text = profile.telephone!;
      if (profile.profession != null) _professionController.text = profile.profession!;
      if (profile.adresse != null) _addressController.text = profile.adresse!;
    }
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs
    _fullNameController.dispose();
    _bioController.dispose();
    _phoneNumberController.dispose();
    _professionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(editControllerProvider);

    // Debug
    print("Etat actuel - Loading: ${state.isLoading}");
    print("Etat actuel - Profil: ${state.profile}");
    print("User name: ${state.profile?.user?.name}");

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 255, 255, 255),
        title: const Text('Modifier le profil',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.orange,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo de profil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path)) as ImageProvider
                        : (state.profile?.avatar != null
                        ? NetworkImage(state.profile!.avatar!)
                        : const AssetImage('assets/default_profile.png')) as ImageProvider,
                    child: _profileImage == null && (state.profile?.avatar == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange[500],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Formulaire
              _buildTextField(
                label: 'Nom complet',
                hintText: 'Entrez votre nom complet',
                controller: _fullNameController,
                validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Bio',
                hintText: 'Décrivez-vous en quelques mots...',
                controller: _bioController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Numéro de téléphone',
                hintText: '+1234567890',
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Profession',
                hintText: 'Votre métier',
                controller: _professionController,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Adresse',
                hintText: 'Votre adresse complète',
                controller: _addressController,
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'ENREGISTRER LES MODIFICATIONS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        filled: true,
        fillColor: const Color.fromARGB(121, 150, 150, 150),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Récupérer les valeurs des contrôleurs
      final fullName = _fullNameController.text;
      final bio = _bioController.text;
      final phoneNumber = _phoneNumberController.text;
      final profession = _professionController.text;
      final address = _addressController.text;

      // TODO: Implémenter la logique de sauvegarde avec les nouvelles valeurs
      print('Profil sauvegardé:');
      print('Nom: $fullName');
      print('Bio: $bio');
      print('Téléphone: $phoneNumber');
      print('Profession: $profession');
      print('Adresse: $address');
      print('Image: ${_profileImage?.path}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green[500],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}