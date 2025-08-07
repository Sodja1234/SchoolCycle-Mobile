class PutPassword{
  final String old_password;
  final String new_password;
  final String password_confirmation;

  PutPassword({
    required this.old_password,
    required this.new_password,
    required this.password_confirmation
  });

  factory PutPassword.fromJson(json) => PutPassword(
      old_password: json["old_password"],
      new_password: json["new_password"],
      password_confirmation: json["password_confirmation"]
  );

  Map<String,dynamic>  toJson() => {
    'old_password' : old_password,
    'new_password' : new_password,
    'password_confirmation' : password_confirmation
  };
}