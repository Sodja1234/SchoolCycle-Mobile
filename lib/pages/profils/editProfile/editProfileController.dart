import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/main.dart';

import '../../../business/services/user/userNetworkService.dart';
import '../../auth/login/loginCtrl.dart';
import 'editProfileState.dart';

class EditProfileController extends StateNotifier<EditProfileState> {
  var userService = getIt.get<UserNetworkService>();
  final Ref ref;

  EditProfileController({
    required this.ref,
  }) : super(EditProfileState()) {
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    await Future.delayed(Duration.zero); // Permet au widget de s'initialiser
    await loadProfile();
  }

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    final loginState = ref.read(LoginCtrlProvider);
    final token = loginState.user?.token;

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        errorMsg: "Token d'authentification manquant",
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMsg: null);

    try {
      final profile = await userService.getProfileTutor(token);
      print("Profil chargé: $profile");

      if (profile == null) {
        throw Exception("Le profil retourné est null");
      }

      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e, stack) {
      print("Erreur lors du chargement: $e");
      debugPrintStack(stackTrace: stack);

      state = state.copyWith(
        errorMsg: "Échec du chargement: ${e.toString()}",
        isLoading: false,
      );
    }
  }
}

final editControllerProvider = StateNotifierProvider<EditProfileController,EditProfileState>((ref) => EditProfileController(ref: ref));