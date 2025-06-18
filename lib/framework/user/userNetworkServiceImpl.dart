
import 'dart:convert';

import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';

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
     var url = '$baseUrl/register/';
     var body = registerUser.toJson();
     var response = await httpUtils.postData(url , body: body);
     print(response);
     return ;
  }

  @override
  Future<void> verifyOtp(VerifyOtp verifyOtp) async {
    var url = '$baseUrl/verify-otp';
    var body = verifyOtp.toJson();
    var response = await httpUtils.postData(url, body : body);
    print(response);
    return ;
  }

  @override
  Future<void> resendOtp(VerifyOtp resendOtp)async {
    var url = '$baseUrl/resend-otp';
    var body = resendOtp.toJson();
    var response = await httpUtils.postData(url, body: body);
    print(response);
    return;
  }

}

void main() async {
  //test register
  var service = UserNetworkServiceImpl(
    baseUrl: "http://10.20.20.140:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  try{
    var data=RegisterUser(name: "name", email: "email@gmail.com", password: "assword", passwordConfirmation: "password");
    var r=await service.registerUser(data);

  }catch(e, s){
    print(e);
    print(s);
  }
  /*var user = VerifyOtp(email: 'legigiiibabyyy@gmail.com');
  try{
    await service.resendOtp(user);
  }on HttpRequestException catch(e){
    print('errueur : ${e.body}');
  }catch(e){
    print('erreur : $e');
  }*/
}
