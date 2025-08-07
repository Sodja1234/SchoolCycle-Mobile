import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_mobile_template/pages/annnouncementList/announcementListPage.dart';
import 'package:odc_mobile_template/pages/auth/login/loginPage.dart';
import 'package:odc_mobile_template/pages/auth/register/registerPage.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpPage.dart';
import 'package:odc_mobile_template/pages/createAnnouncement/createAnnouncementPage.dart';
import 'package:odc_mobile_template/pages/detailAnnouncement/detailAnnouncementPage.dart';
import 'package:odc_mobile_template/pages/profils/changePassword/changePasswordPage.dart';
import 'package:odc_mobile_template/pages/profils/editProfile/editProfilePage.dart';
import 'package:odc_mobile_template/pages/profils/userPreference/userPreferencePage.dart';
import 'package:odc_mobile_template/pages/widgets/mainLayout.dart';
import 'pages/404/not_found_page.dart';
import 'pages/intro/appCtrl.dart';
import 'pages/intro/introPage.dart';
import 'utils/navigationUtils.dart';
import './main.dart';
import 'pages/home/homePage.dart';

final routerConfigProvider = Provider<GoRouter>((ref) {
  final navigatorKey = getIt<NavigationUtils>().navigatorKey;
  /*
   routes restreintes
  */
  final authRoutes = [
    GoRoute(
      path: "/app/home",
      name: 'home_page',
      builder: (ctx, state) {
        return Consumer(
          builder: (context, ref, _) {
            return const MainLayout();
          },
        );
      },
    ),
  ];

  /*
   routes publics
  */
  final noAuthRoutes = [
    GoRoute(
      path: "/public/intro",
      name: 'intro_page',
      builder: (ctx, state) {
        return IntroPage();
      },
    ),

    //route login
    GoRoute(
      path: "/public/auth/loginPage",
      name: "login_page",
      builder: (ctx, state) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: "/public/auth/registerPage",
      name: "register_page",
      builder: (ctx, state) {
        return RegisterPage();
      },
    ),
    //route verifyOtp
    GoRoute(
      path: "/public/auth/verifyOtp",
      name: "verify_otp_page",
      builder: (ctx, state) {
        return VerifyOtpPage();
      },
    ),
    // route detail announcement
    GoRoute(
      path: "/public/detail_announcement/:announcementId",
      name: 'detail_announcement',
      pageBuilder: (ctx, state) {
        final announcementId = int.parse(
          state.pathParameters["announcementId"]!,
        );
        return MaterialPage(
          child: DetailAnnouncementPage(announcementId: announcementId),
        );
      },
    ),
    // route pour créer une nouvelle annonce
    GoRoute(
      path: '/public/create_announcement',
      name: 'create_announcement',
      builder: (ctx, state) {
        return CreateAnnouncementPage();
      },
    ),
    GoRoute(
      path: '/public/announcementList',
      name: 'announcement_list',
      builder: (ctx, state) {
        return AnnouncementListPage();
      },
    ),
    GoRoute(
      path: '/public/changePassword',
      name: 'change_password',
      builder: (ctx, state) {
        return ChangePasswordPage();
      },
    ),
  ];

  /*
CONFIGURATION  DES ROUTES
*/
  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/public/intro",
    redirect: (context, state) async{
      final appState = ref.read(appCtrlProvider);
      final isAuthInProgress = appState.user == null && appState.error == null;

      // Attendez la fin du chargement initial
      if (isAuthInProgress) {
        await ref.read(appCtrlProvider.notifier).getUser();
      }

      final user = ref.read(appCtrlProvider).user;

      if (user != null && state.matchedLocation.startsWith("/public/auth")) {
        return "/app/home"; // Redirige seulement les routes auth
      }

      return null;
    },
    routes: [...noAuthRoutes, ...authRoutes],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
