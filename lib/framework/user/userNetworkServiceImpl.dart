
import 'dart:convert';

import 'package:odc_mobile_template/business/models/user/registerUser.dart';

import '../../business/models/user/authentication.dart';

import '../../business/models/user/user.dart';

import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpRequestException.dart';
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

  @override
  Future<void> registerUser(RegisterUser registerUser) async{
   //try{
     var url = '$baseUrl/register';
     var body = registerUser.toJson();
     var response = await httpUtils.postData(url , body: body, headers: {'X-Device': 'mobile'});
     print(response);
     return ;
  }
}



void main() async {
  //test register
  var service = UserNetworkServiceImpl(
    baseUrl: "http://127.0.0.1:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  var register = RegisterUser(
      name: 'test2',
      email: 'gigitest222@gmail.com',
      password: '667667667',
      passwordConfirmation: '667667667',
      role: 'tutor'
  );

  try{
    await service.registerUser(register);
  }catch(e){
    print('erreur : $e');
  }
}
