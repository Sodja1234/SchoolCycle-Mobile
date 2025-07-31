import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/annnouncementList/announcementListPage.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/home/homePage.dart';
import 'package:odc_mobile_template/pages/home/homeWidget.dart';
import 'package:odc_mobile_template/pages/messages/messagePage.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';

import '../profil/profilePage.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomePage(),
    AnnouncementListPage(), // Page de recherche
    MessagePage(), // Page des messages
    ProfilePage(), // Page de profil
  ];

  static final List<Map<String, dynamic>> _items = [
    {'icon': Icons.home_outlined, 'label': 'Accueil'},
    {'icon': Icons.search_outlined, 'label': 'Recherche'},
    {'icon': Icons.chat_bubble_outline, 'label': 'Messages'},
    {'icon': Icons.person_outlined, 'label': 'Profil'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var navigation = getIt<NavigationUtils>();

  @override
  Widget build(BuildContext context) {
    
    var userLocal = ref.watch(LoginCtrlProvider);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
          onPressed: () async {
            // Action à effectuer lors du clic sur le bouton flottant
            // navigation.navigate('/public/create_announcement');
            print("tap detecté");
            if (userLocal.user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Veuillez vous connecter pour créer une annonce",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Color(0xFFFF6B35),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).size.height *
                        0.1, // Position au-dessus du BottomNavBar
                    left: 20,
                    right: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              await Future.delayed(Duration(seconds: 2, milliseconds: 300));
              if (context.mounted) {
                navigation.navigate('/public/auth/loginPage');
              }
            } else {
              // si connecté
              navigation.navigate('/public/create_announcement');
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                HomeWidgets.navbarItem(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  item: _items[0],
                  onTap: _onItemTapped,
                ),
                HomeWidgets.navbarItem(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  item: _items[1],
                  onTap: _onItemTapped,
                ),
                SizedBox(width: 40),
                HomeWidgets.navbarItem(
                  index: 2,
                  selectedIndex: _selectedIndex,
                  item: _items[2],
                  onTap: _onItemTapped,
                ),
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