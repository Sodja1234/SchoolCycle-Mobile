// To parse this JSON data, do
//
//     final registerUser = registerUserFromJson(jsonString);

import 'dart:convert';

RegisterUser registerUserFromJson(String str) => RegisterUser.fromJson(json.decode(str));

String registerUserToJson(RegisterUser data) => json.encode(data.toJson());

class RegisterUser {
  String name;
  String email;
  String password;
  String passwordConfirmation;
  String? role;

  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.role,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) => RegisterUser(
    name: json["name"],
    email: json["email"],
    password: json["password"],
    passwordConfirmation: json["password_confirmation"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "password": password,
    "password_confirmation": passwordConfirmation,
    "role": role,
  };
}
