

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpState.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';

import '../../../main.dart';

class VerifyOtpCtrl extends StateNotifier<VerifyOtpState>{
  final userNetorkservice = getIt.get<UserNetworkService>();
  VerifyOtpCtrl() : super(VerifyOtpState());

  Future<bool> verifyOtp(VerifyOtp verifyOtp)async{
    state = state.copyWith(
        isSubmited: true,
      successMessage: null,
      errorMessage: null
    );
    try{
      await userNetorkservice.verifyOtp(verifyOtp);
      state = state.copyWith(
          isSubmited: false,
        successMessage: 'Email vérifié avec succès'
      );
      durationToast();
      return true;
    }on HttpRequestException catch(e){
      state = state.copyWith(
          isSubmited: false,
        errorMessage: "${e.body}"
      );
      durationToast();
      print(e.body);
      return false;
    }on TimeoutException catch(e){
      state = state.copyWith(
        isSubmited : false,
        errorMessage: "Temps d'attente dépassé. Le serveur ne répond pas.",
      );
      durationToast();
      return false;
    }catch(e){
      state = state.copyWith(
        isSubmited: false,
        errorMessage: "Erreur serveur : $e",
      );
      durationToast();
      return false;
    }
  }

  Future<bool> resendOtp(VerifyOtp resendOtp)async{
    state = state.copyWith(
        isSubmited: true,
      successMessage: null,
      errorMessage: null
    );
    try{
      await userNetorkservice.resendOtp(resendOtp);
      state = state.copyWith(
          isSubmited: false,
        successMessage: 'Un code a ete renvonyé'
      );
      durationToast();
      return true;
    }on HttpRequestException catch(e){
      state = state.copyWith(
        isSubmited: false,
        errorMessage:  '${e.body}',
      );
      durationToast();
      return false;
    }on TimeoutException catch(_){
      state = state.copyWith(
          isSubmited: false,
        errorMessage: "Temps d'attente dépassé. Le serveur ne répond pas."
      );
      durationToast();
      return false;
    }catch(e){
      state = state.copyWith(
          isSubmited: false,
        errorMessage: '$e'
      );
      durationToast();
      return false;
    }
  }

  // Nettoie les messages d'erreur et de succès (ex. après affichage)
  void resetMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  durationToast(){
    Future.delayed(Duration(seconds: 3),(){
      resetMessages();
    });
  }
}

final VerifyOtpCtrlProvider  = StateNotifierProvider<VerifyOtpCtrl, VerifyOtpState>((ref){
  return VerifyOtpCtrl();
});
