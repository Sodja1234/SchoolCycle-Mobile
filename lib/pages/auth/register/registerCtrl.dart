
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/pages/auth/register/registerState.dart';

import '../../../main.dart';
import '../../../utils/http/HttpRequestException.dart';

class RegisterCtrl extends StateNotifier<RegisterState>{


  final UserNetworkService network = getIt.get<UserNetworkService>();

  RegisterCtrl() : super(RegisterState());
  
  Future<bool> register(RegisterUser registerUser) async {
    state = state.copyWith(
      isSubmited: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      await network.registerUser(registerUser);
      state = state.copyWith(
        isSubmited: false,
        successMessage: "Inscription réussie !",
        email: registerUser.email,
      );
      durationToast();
      return true;
    }on HttpRequestException catch (e) {
      state = state.copyWith(
        isSubmited: false,
        errorMessage: "${e.body.toString()}",
      );
      print('error : ${e.body}');
      durationToast();
      return false;
    }on TimeoutException catch (_) {
      state = state.copyWith(
        isSubmited : false,
        errorMessage: "Temps d'attente dépassé. Le serveur ne répond pas.",
      );
      durationToast();
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmited: false,
        errorMessage: "Erreur serveur : $e",
      );
      durationToast();
      return false;
    }
  }

  // Méthode resetMessages
  void resetMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
      isSubmited: false,
    );
  }

  void durationToast(){
    Future.delayed(Duration(seconds: 3),(){
      resetMessages();
    });
  }

}

final RegisterCtrlProvider = StateNotifierProvider<RegisterCtrl, RegisterState>((ref){
  return RegisterCtrl();
});