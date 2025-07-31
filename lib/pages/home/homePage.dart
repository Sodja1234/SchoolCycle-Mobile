import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/home/homeCtrl.dart';
import 'package:odc_mobile_template/pages/home/homeWidget.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex =
      0; // Index de l'élément sélectionné dans la barre de navigation

  // Contrôleurs pour gérer les animations et le carrousel (slider)
  late PageController
  _pageController; // Permet de contrôler le widget PageView .
  Timer? _sliderTimer;
  int _currentSliderPage =
      0; // // Stocke l’index actuel de la page affichée dans le slide

  bool _isAnimating = false;
  // Initialisation des animations et du carrousel lors du lancement de la page
  @override
  void initState() {
    super.initState();
    // Contrôleur pour le carrousel d'images
    _pageController = PageController(initialPage: 0);

    // Lance le timer pour le défilement automatique du carrousel
    _startSliderTimer();
  }

  void _initAnimations() {
    _pageController = PageController(initialPage: 0);
    _startSliderTimer();
  }

  // Lance un timer qui fait défiler automatiquement les slides toutes les 5 secondes
  // void _startSliderTimer() {
  //   _sliderTimer?.cancel();
  //   _sliderTimer = Timer.periodic(Duration(seconds: 5), (timer) {
  //     if (_pageController.hasClients) {
  //       final newPage =
  //           _currentSliderPage < _slides.length - 1
  //               ? _currentSliderPage + 1
  //               : 0;

  //       _pageController
  //           .animateToPage(
  //             newPage,
  //             duration: Duration(milliseconds: 800),
  //             curve: Curves.easeInOut,
  //           )
  //           .then((_) {
  //             if (mounted) setState(() => _currentSliderPage = newPage);
  //           });
  //     }
  //   });
  // }

  void _startSliderTimer() {
  _sliderTimer?.cancel();
  _sliderTimer = Timer.periodic(Duration(seconds: 5), (timer) {
    if (_pageController.hasClients && !_isAnimating) {
      final newPage = _currentSliderPage < _slides.length - 1 ? _currentSliderPage + 1 : 0;

      _isAnimating = true;
      _pageController
          .animateToPage(
            newPage,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (mounted) setState(() => _currentSliderPage = newPage);
            _isAnimating = false;
          });
    }
  });
}

  // Libère les ressources lors de la destruction du widget
  @override
  void dispose() {
    _pageController.dispose();
    _sliderTimer?.cancel();
    super.dispose();
  }

  // Définition des éléments de la barre de navigation inférieure
  static List<Map<String, dynamic>> _items = [
    {'icon': Icons.home_outlined, 'label': 'Accueil'},
    {'icon': Icons.search_outlined, 'label': 'Recherche'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Messages'},
    {'icon': Icons.person_outlined, 'label': 'Profil'},
  ];

  // Liste des catégories affichées sous forme de cartes
  static List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.menu_book_rounded,
      'label': 'Livres',
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
    },
    {
      'icon': Icons.edit_rounded,
      'label': 'Stylos',
      'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
    },
    {
      'icon': Icons.school_rounded,
      'label': 'Cartables',
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
    },
    {
      'icon': Icons.straighten_rounded,
      'label': 'Règles',
      'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)],
    },
    {
      'icon': Icons.palette_rounded,
      'label': 'Crayons',
      'gradient': [Color(0xFFfa709a), Color(0xFFfee140)],
    },
    {
      'icon': Icons.backpack_rounded,
      'label': "Sac à dos",
      'gradient': [Color(0xFFa8edea), Color(0xFFfed6e3)],
    },
  ];

  // Slides du carrousel principal (bannières promotionnelles)
  static List<Map<String, dynamic>> _slides = [
    {
      'title': 'Rentrée Scolaire',
      'subtitle': "Jusqu'à -50% sur les fournitures",
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Échange Gratuit',
      'subtitle': 'Trouvez ce dont vous avez besoin',
      'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
      'icon': Icons.swap_horiz_rounded,
    },
    {
      'title': 'Dons Solidaires',
      'subtitle': 'Aidez la communauté étudiante',
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': Icons.favorite_rounded,
    },
  ];

  // Met à jour l'index sélectionné lors d'un clic sur la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var navigation = getIt<NavigationUtils>();
  

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;
    double horizontalPadding = (screenWidth - cardWidth) / 2;

    final state = ref.watch(homeCtrlProvider);
    // print("La liste d'annonce : ${state.announcements}");
    final ctrl = ref.read(homeCtrlProvider.notifier);
    final userLocal = ref.watch(LoginCtrlProvider);

    print(
       "État de connexion: ${userLocal.user != null ? 'Connecté' : 'Non connecté'}",
    );

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu_book_outlined, color: const Color(0xFFFF7F07)),
        title: Text(
          'SchoolCycle',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFFF9000),
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.brightness_4, color: Color(0xFFFF6B35)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            // affichage barre de recherche
            HomeWidgets.buildSearchBar(),
            SizedBox(height: 16),
            // Affichage du carrousel
            HomeWidgets.buildHeroSection(
              slides: _slides,
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentSliderPage = index;
                });
              },
            ),

            // les boutons des gestions du carrousel
            HomeWidgets.buildSliderIndicator(
              currentPage: _currentSliderPage,
              slideCount: _slides.length,
            ),
            SizedBox(height: 24),

            // Section catégories
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return HomeWidgets.categoryCard(
                    category: _categories[index],
                    onTap: () {
                      // redirection vers la pages announceByCategory
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 32),

            // Annonces récentes
            HomeWidgets.titreSection(
              title: "Annonces Récentes",
              subtitle: 'Découvrez les dernières offres de la communauté',
              onSeeAll: () {
                navigation.navigate("/public/announcementList");
              },
            ),

            SizedBox(height: 16),
            Container(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.announcements?.length ?? 0,
                itemBuilder: (context, index) {



                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.announcements![index],
                        onFavoriteTap: () {
                          // la redirection vers la page detailAnnouncement
                        },
                        onTap: () {
                          debugPrint("Announcement tapped: ${state.announcements![index].id}");
                          navigation.navigate(
                            '/public/detail_announcement/${state.announcements![index].id}',
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 32),

            // Suggestions
            HomeWidgets.titreSection(
              title: 'Suggestions pour vous',
              subtitle: 'Basées sur vos préférences et recherches',
              onSeeAll: () => {
                navigation.navigate("/public/announcementList")
              },
            ),

            SizedBox(height: 16),

            Container(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.announcements?.length ?? 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.announcements![index],
                        onTap: () {
                          navigation.navigate(
                            '/public/detail_announcement/${state.announcements![index].id}',
                          );
                        },
                        onFavoriteTap: () {
                          // ajouter en favoris
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 32),

            // Ventes
            HomeWidgets.titreSection(
              title: 'Ventes de Fournitures',
              subtitle: 'Les meilleures offres à petits prix',
              onSeeAll: () {
                navigation.navigate("/public/announcementList");
              },
            ),

            SizedBox(height: 16),
            Container(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.salesAnnouncements?.length ?? 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.salesAnnouncements![index],
                        onTap: () {
                          print("L'id de l'annonce cliqué : ${state.announcements![index].id}");
                          navigation.navigate(
                            '/public/detail_announcement/${state.salesAnnouncements![index].id}',
                          );
                        },
                        onFavoriteTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 32),

            // Échanges
            HomeWidgets.titreSection(
              title: 'Échanges Possibles',
              subtitle: 'Trouvez des personnes pour échanger sans argent',
              onSeeAll: () {
                navigation.navigate("/public/announcementList");
              },
            ),

            SizedBox(height: 16),
            Container(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.exchangeAnnouncements?.length ?? 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.exchangeAnnouncements![index],
                        onTap: () {
                          navigation.navigate(
                            '/public/detail_announcement/${state.exchangeAnnouncements![index].id}',
                          );
                        },
                        onFavoriteTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 32),

            // Dons
            HomeWidgets.titreSection(
              title: 'Dons Possibles',
              subtitle: 'Des fournitures offertes par la communauté',
              onSeeAll: () {
                navigation.navigate("/public/announcementList");
              },
            ),

            SizedBox(height: 16),
            Container(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.donationAnnouncements?.length ?? 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.donationAnnouncements![index],
                        onTap: () {
                          navigation.navigate(
                            '/public/detail_announcement/${state.donationAnnouncements![index].id}',
                          );
                        },
                        onFavoriteTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
      resizeToAvoidBottomInset:
          false, // empecher flutter d'ajuster automatiquement la mise en page
    );
  }
}
