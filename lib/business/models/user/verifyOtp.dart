
import 'dart:convert';

VerifyOtp VerifyOtpFromJson(String str) => VerifyOtp.fromJson(json.decode(str));

String VerifyOtpToJson(VerifyOtp data) => json.encode(data.toJson());

class VerifyOtp {
  String? email;
  String? otp;

  VerifyOtp({
     this.email,
     this.otp,
  });

  factory VerifyOtp.fromJson(Map<String, dynamic> json) => VerifyOtp(
    email: json["email"],
    otp: json["opt"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
  };
}
