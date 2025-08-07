import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/auth/login/loginState.dart';
import 'package:odc_mobile_template/pages/profils/profil/profileController.dart';
import 'package:odc_mobile_template/pages/profils/profil/profileState.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import '../../../main.dart';
import '../../intro/appCtrl.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _selectedIndex = 0;
  late NavigationUtils navigation;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    navigation = getIt<NavigationUtils>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final user = ref.read(LoginCtrlProvider).user;
    if (user != null && user.token != null) {
      await ref.read(profileControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(LoginCtrlProvider).user;
    final state = ref.watch(profileControllerProvider);

    ref.listen<LoginState>(LoginCtrlProvider, (previous, next) {
      if (next.user == null && previous?.user != null) {
        // Force un refresh de l'UI et des données
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(profileControllerProvider); // Invalide le provider
          setState(() {}); // Force un rebuild
        });
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(249, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          user == null
              ? _buildNotConnectedView()
              : _buildConnectedView(user, state),
    );
  }

  Widget _buildNotConnectedView() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Vous n\'êtes pas connecté',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Connectez-vous pour accéder à votre profil et à toutes les fonctionnalités',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    navigation.navigate("/public/auth/loginPage");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  navigation.navigate("/public/auth/registerPage");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedView(User user, ProfilState state) {
    return Column(
      children: [
        // Section info utilisateur
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  _selectedIndex == 0
                      ? 'Rechercher vos annonces...'
                      : 'Rechercher dans vos favoris...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  if (user.token != null) {
                    if (_selectedIndex == 0) {
                      ref
                          .read(profileControllerProvider.notifier)
                          .searchUserAnnouncements('', user.token!);
                    } else {
                      ref
                          .read(profileControllerProvider.notifier)
                          .searchFavoriteAnnouncements('', user.token!);
                    }
                  }
                },
                icon: const Icon(Icons.clear),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              if (user.token != null) {
                if (_selectedIndex == 0) {
                  ref
                      .read(profileControllerProvider.notifier)
                      .searchUserAnnouncements(value, user.token!);
                } else {
                  ref
                      .read(profileControllerProvider.notifier)
                      .searchFavoriteAnnouncements(value, user.token!);
                }
              }
            },
          ),
        ),

        // Onglets
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              _buildTabButton(0, 'Mes annonces'),
              _buildTabButton(1, 'Favoris'),
              _buildTabButton(2, 'Paramètres'),
            ],
          ),
        ),

        // Contenu des onglets
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildMyAnnouncements(state),
              _buildFavorites(state, user),
              _buildSettings(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String text) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    _selectedIndex == index
                        ? Colors.orange
                        : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.orange : Colors.grey,
                fontWeight:
                    _selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyAnnouncements(ProfilState state) {
    final userAnnouncements = state.announcements;

    return _buildAnnouncementsList(state, userAnnouncements);
  }

  Widget _buildAnnouncementsList(
    ProfilState state,
    List<Announcement>? announcements,
  ) {
    if (state.isLoading ?? true) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Erreur: ${state.error}'));
    }

    if (announcements == null || announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.announcement_outlined,
              size: 50,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune annonce trouvée',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
            TextButton(
              onPressed: () {
                ref.read(profileControllerProvider.notifier).refresh();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildFullWidthAnnouncementCard(announcements[index]),
        );
      },
    );
  }

  Widget _buildFullWidthAnnouncementCard(Announcement announcement) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          navigation.navigate("/public/detail_announcement/${announcement.id}");
        },
        child: Column(
          children: [
            Container(
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child:
                          announcement.photos?.isNotEmpty == true
                              ? Image.network(
                                "${dotenv.env["BASE_URL"]?.replaceFirst("/api", "/storage/")}${announcement.photos?.first.url}",
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                              )
                              : const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        announcement.operation_type == "sale"
                            ? "Vente"
                            : announcement.operation_type == "exchange"
                            ? "Échange"
                            : announcement.operation_type == "don"
                            ? "Don"
                            : "Autre",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.red[400],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          announcement.title ?? 'Titre indisponible',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          announcement.exchange_location_address ??
                              'Localisation inconnue',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        announcement.price != null
                            ? "${announcement.price} Fc"
                            : "Gratuit",
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorites(ProfilState state, User user) {
    final favorites = state.announcementFavorites;

    return Column(
      children: [
        if (state.isLoading ?? false)
          const LinearProgressIndicator(minHeight: 2),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (user.token != null) {
                await ref
                    .read(profileControllerProvider.notifier)
                    .getFavoritesAnnouncements(user.token!);
              }
            },
            child: _buildAnnouncementsList(state, favorites),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Modifier mes informations',
          onTap: () {
            navigation.navigate("/public/editProfile");
          },
        ),
        _buildSettingsItem(
          icon: Icons.favorite_border,
          title: 'Préférences de favoris',
          onTap: () {
            navigation.navigate("/public/userPreference");
          },
        ),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'Changer le mot de passe',
          onTap: () {
            navigation.navigate("/public/changePassword");
          },
        ),
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Déconnexion',
          onTap: () async {
            try {
              // Attendre que la déconnexion soit complète
              await ref.read(profileControllerProvider.notifier).logout();
              ref.invalidate(profileControllerProvider);
              ref.invalidate(appCtrlProvider);

              // Invalider le provider pour forcer un refresh complet
              ref.invalidate(profileControllerProvider);

              // Afficher le message de succès
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Vous êtes déconnecté.',
                    style: TextStyle(fontSize: 16),
                  ),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              // Naviguer seulement après que tout est terminé
              navigation.navigate("/app/home");
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erreur lors de la déconnexion: ${e.toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.orange),
        title: Text(
          title,
          style: TextStyle(color: isLogout ? Colors.red : Colors.black),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
