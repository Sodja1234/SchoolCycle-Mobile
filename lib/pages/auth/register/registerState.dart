import 'dart:convert';
import 'package:odc_mobile_template/business/models/user/user.dart';

RegisterState registerStateFromJson(String str) => RegisterState.fromJson(json.decode(str));

String registerStateToJson(RegisterState data) => json.encode(data.toJson());

class RegisterState {
  bool? isSubmited;
  String? successMessage;
  String? errorMessage;
  User? user;

  RegisterState({
     this.isSubmited ,
     this.successMessage,
     this.errorMessage,
     this.user,
  });

  RegisterState copyWith({
    bool? isSubmited,
    String? successMessage,
    String? errorMessage,
    User? user,
  }) =>
      RegisterState(
        isSubmited: isSubmited ?? this.isSubmited,
        successMessage: successMessage ?? this.successMessage,
        errorMessage: errorMessage ?? this.errorMessage,
        user: user ?? this.user,
      );

  factory RegisterState.fromJson(Map<String, dynamic> json) => RegisterState(
    isSubmited: json["isSubmited"],
    successMessage: json["successMessage"],
    errorMessage: json["errorMessage"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "isSubmited": isSubmited,
    "successMessage": successMessage,
    "errorMessage": errorMessage,
    "user": user?.toJson(),
  };
}
