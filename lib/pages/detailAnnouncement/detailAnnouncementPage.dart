import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/detailAnnouncement/detailAnnouncementController.dart';
import 'package:odc_mobile_template/pages/detailAnnouncement/detailAnnouncementWidget.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/share_plus.dart';

class DetailAnnouncementPage extends ConsumerStatefulWidget {
  final int announcementId;

  DetailAnnouncementPage({Key? key, required this.announcementId});

  @override
  ConsumerState<DetailAnnouncementPage> createState() =>
      _DetailAnnouncementPageState();
}

class _DetailAnnouncementPageState extends ConsumerState<DetailAnnouncementPage>
    with TickerProviderStateMixin {
  late AnimationController
  _animationController; // Contrôleur pour gérer les animations (démarrage, arrêt, durée)
  late Animation<double>
  _fadeAnimation; // Animation pour l'effet de fondu (opacité de 0 à 1)
  late Animation<Offset>
  _slideAnimation; // Animation pour le glissement depuis le bas

  // Index de l'image actuellement sélectionnée dans la galerie
  // Initialisé à 0 pour afficher la première image par défaut
  int _selectedImageIndex = 0;

  // État du bouton favori (true = activé, false = désactivé)
  // Initialisé à false par défaut
  bool _isFavorite = false;

  var navigation = getIt<NavigationUtils>();

  @override
  void initState() {
    super.initState();

    _initializeAnimations(); // Initialise les animations au démarrage de la page

    // Charger l'article au lancement de la page
    // Charge les données de l'annonce de manière asynchrone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(DetailAnnouncementProvider.notifier)
          .loadAnnouncementData(widget.announcementId);
    });
  }

  void _initializeAnimations() {
    // Crée un contrôleur d'animation avec une durée de 800ms
    // vsync: this permet de synchroniser avec les frames d'affichage
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Configure l'animation de fondu (opacité de 0 à 1)
    // avec une courbe d'accélération/décélération
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Configure l'animation de glissement depuis le bas (30% de la hauteur)
    // avec une courbe cubique pour un effet plus dynamique
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // Nettoie le contrôleur d'animation pour éviter les fuites de mémoire
    // Doit être appelé quand l'état n'est plus nécessaire
    _animationController.dispose();
    super.dispose();
  }

  // la meethode permettant de partager l'annonce
  void _shareAnnouncement(Announcement announcement) async {
    try {
      final box = context.findRenderObject() as RenderBox?;

      await Share.share(
        'Découvrez cette annonce sur SchoolCycle:\n\n'
        '📌 ${announcement.title}\n\n'
        '📝 ${announcement.description ?? "Pas de description"}\n\n'
        '💰 Prix: ${announcement.price != null ? "${announcement.price} Fc" : "Gratuit"}',
        subject: 'Annonce SchoolCycle - ${announcement.title}',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box!.size,
      );
    } on PlatformException catch (e) {
      debugPrint('Erreur PlatformException lors du partage: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.message ?? "Partage non disponible"}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur inattendue lors du partage: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de partager: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(DetailAnnouncementProvider);
    print("ID ${widget.announcementId}");
    var ctrl = ref.watch(DetailAnnouncementProvider.notifier);
    var user = ref.watch(LoginCtrlProvider).user;
    final isUserLoggedIn = user != null;
    bool isOwner = state.announcement?.created_by?.id == user?.id;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: Color(0xFFFF9000)),
        ),
        title: Text(
          'Détail de l\'annonce',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF9000),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child:
              state.isLoading == true
                  ? Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFFF9000),
                    ),
                  )
                  : state.announcement == null
                  ? Center(child: Text("Annonce introuvable"))
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        DetailAnnouncementWidget.imageGallery(
                          state.announcement!,
                          _selectedImageIndex,
                          (index) {
                            setState(() {
                              _selectedImageIndex = index;
                            });
                          },
                          _isFavorite,
                          () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          isUserLoggedIn
                        ),
                        SizedBox(height: 16),

                        // section info de l'annonce
                        DetailAnnouncementWidget.infoSection(
                          state.announcement!,
                        ),

                        // la carte avec la localisation
                        DetailAnnouncementWidget.buildLocationSection(
                          state.announcement!,
                          context,
                        ),

                        // les informations du proprietaire
                        DetailAnnouncementWidget.ownerSection(
                          state.announcement!,
                        ),

                        // les boutons envoyer un message,partage et signaler
                        DetailAnnouncementWidget.buildActionButtons(
                          context,

                          () => DetailAnnouncementWidget.showMessageDialog(
                            context,state.announcement!
                          ),

                          () => {_shareAnnouncement(state.announcement!)},

                          () => DetailAnnouncementWidget.showReportDialog(
                            context,
                          ),
                          isUserLoggedIn,
                          isOwner
                        ),

                        // Les annonces simulaires
                        DetailAnnouncementWidget.buildSimilarAnnouncements(
                          state.similarAnnouncements!,
                          context,
                          // La methode pour la redirection vers detailAnnonce
                          (id) {
                            print("dddd");
                            navigation.navigate(
                              "/public/detail_announcement/${id}",
                            );
                          },
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
