
import 'dart:convert';

import '../../business/models/user/authentication.dart';

import '../../business/models/user/user.dart';

import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<User> recupererInfoUtilisateur() {
    // TODO: implement recupererInfoUtilisateur
    throw UnimplementedError();
  }

  @override
  Future<User?> seConnecter(Authentication authentication) async{
    try{
      var url = '$baseUrl/login';
      var body = authentication.toJson() ;
      var response = await httpUtils.postData(url, body : body);
      print(response);
      var decoded = jsonDecode(response);
      var user = User.fromJson(decoded);
      return user;

    }catch(e){
      print('error : $e');
      throw Exception('Erreur lors de la connexion : $e');
    }
  }
}


//test Login
void main() async {
  var service = UserNetworkServiceImpl(
    baseUrl: "http://127.0.0.1:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  var auth = Authentication(email: "breeze@gmail.com", password: "667667667");
  try {
    var user = await service.seConnecter(auth);
    print("Utilisateur connecté : ${user?.name}");
  } catch (e) {
    print("Erreur : $e");
  }
}
