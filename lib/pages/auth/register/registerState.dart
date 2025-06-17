import 'dart:convert';
import 'package:odc_mobile_template/business/models/user/user.dart';


class RegisterState {
  bool? isSubmited;
  String? successMessage;
  String? errorMessage;
  String? email;

  RegisterState({
     this.isSubmited ,
     this.successMessage,
     this.errorMessage,
     this.email,
  });

  RegisterState copyWith({
    bool? isSubmited,
    String? successMessage,
    String? errorMessage,
    String? email,
  }) =>
      RegisterState(
        isSubmited: isSubmited ?? this.isSubmited,
        successMessage: successMessage,
        errorMessage: errorMessage ,
        email: email ?? this.email,
      );

  // Fabrique un état initial (valeurs par défaut)
  factory RegisterState.initial() {
    return RegisterState(
      isSubmited: false,
      errorMessage: null,
      successMessage: null,
    );
  }

}
