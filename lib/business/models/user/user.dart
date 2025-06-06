//generate class user with optional fields and toJosn and fromJson methods

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? token;
  final String? email_verified_at;

  User({this.id, this.name, this.email, this.token, this.email_verified_at});

  factory User.fromJson(json) => User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token : json['token'],
      email_verified_at : json['email_verified_at']
  );

  Map toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'token' : token,
    'email_verified_at' : email_verified_at
  };
}
