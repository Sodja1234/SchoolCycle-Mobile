import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/pages/home/homeCtrl.dart';
import 'package:odc_mobile_template/pages/home/homeWidget.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}


class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  
  // TickerProviderStateMixin permet la gestion des animations
  int _selectedIndex = 0; // Index de l'élément sélectionné dans la barre de navigation

  // Contrôleurs pour gérer les animations et le carrousel (slider)
  late AnimationController _animationController; // Contrôle l'animation (durée, démarrage, arrêt) — utilisé pour animer les transitions.
  late Animation<double> _fadeAnimation; // Définit une animation de type double (valeurs entre 0 et 1), ici pour créer un effet de fondu.
  late PageController _pageController; // Permet de contrôler le widget PageView .
  Timer? _sliderTimer;  
  int _currentSliderPage = 0;  // // Stocke l’index actuel de la page affichée dans le slide

  // Initialisation des animations et du carrousel lors du lancement de la page
  @override
  void initState() {
    super.initState();

    // Contrôleur pour l'animation de fondu (fade-in)
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Contrôleur pour le carrousel d'images
    _pageController = PageController(initialPage: 0);

    // Lance le timer pour le défilement automatique du carrousel
    _startSliderTimer();
  }

  // Lance un timer qui fait défiler automatiquement les slides toutes les 5 secondes
  void _startSliderTimer() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentSliderPage < _slides.length - 1) {
        _currentSliderPage++;
      } else {
        _currentSliderPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentSliderPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Libère les ressources lors de la destruction du widget
  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _sliderTimer?.cancel();
    super.dispose();
  }

  // Définition des éléments de la barre de navigation inférieure
  final List<Map<String, dynamic>> _items = [
    {'icon': Icons.home_outlined, 'label': 'Accueil'},
    {'icon': Icons.search_outlined, 'label': 'Recherche'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Messages'},
    {'icon': Icons.person_outlined, 'label': 'Profil'},
  ];

  // Liste des catégories affichées sous forme de cartes
  final List<Map<String, dynamic>> _categories = [
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
  final List<Map<String, dynamic>> _slides = [
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeCtrlProvider);
    print("La liste d'annonce : ${state.announcements}");
    final ctrl = ref.read(homeCtrlProvider.notifier);

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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
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
                onSeeAll: () {},
              ),

              SizedBox(height: 16),
              Container(
                height: 320,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    mainAxisExtent: 200,
                  ),
                  itemCount: state.announcements?.length ?? 0,
                  itemBuilder: (context, index) {
                    return HomeWidgets.announcementCard(
                      announcement: state.announcements![index],
                      onFavoriteTap: () {
                        // la redirection vers la page detailAnnouncement
                      },
                      onTap: () {
                        // appel de la methode pour ajouter l'annonce en favoris
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 32),

              // Suggestions
              HomeWidgets.titreSection(
                title: 'Suggestions pour vous',
                subtitle: 'Basées sur vos préférences et recherches',
              ),

              SizedBox(height: 16),

              Container(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.announcements?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.announcements![index],
                        onTap: () {
                          // detail annonnce
                        },
                        onFavoriteTap: () {
                          // ajouter en favoris
                        },
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
                onSeeAll: () {},
              ),

              SizedBox(height: 16),
              Container(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.salesAnnouncements?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.salesAnnouncements![index],
                        onTap: () {},
                        onFavoriteTap: () {},
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
                onSeeAll: () {},
              ),

              SizedBox(height: 16),
              Container(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.exchangeAnnouncements?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.exchangeAnnouncements![index],
                        onTap: () {},
                        onFavoriteTap: () {},
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
                onSeeAll: () {},
              ),

              SizedBox(height: 16),
              Container(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.donationAnnouncements?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 16),
                      child: HomeWidgets.announcementCard(
                        announcement: state.donationAnnouncements![index],
                        onTap: () {},
                        onFavoriteTap: () {},
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false, // empecher flutter d'ajuster automatiquement la mise en page
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B35).withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          splashColor: Colors.transparent,
          highlightElevation: 0,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),

        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // accueil
                HomeWidgets.navbarItem(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  item: _items[0],
                  onTap: _onItemTapped,
                ),
                // recherche
                HomeWidgets.navbarItem(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  item: _items[1],
                  onTap: _onItemTapped,
                ),
                // Espace vide pour le FloatingActionButton
                SizedBox(width: 40),
                // Messages
                HomeWidgets.navbarItem(
                index: 2,
                selectedIndex: _selectedIndex,
                item: _items[2],
                onTap: _onItemTapped,
              ),

              // Profil
              HomeWidgets.navbarItem(
                index: 3,
                selectedIndex: _selectedIndex,
                item: _items[3],
                onTap: _onItemTapped,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
