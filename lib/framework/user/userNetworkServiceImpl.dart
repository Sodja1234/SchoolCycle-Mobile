
import 'dart:convert';

import 'package:odc_mobile_template/business/models/user/profile.dart';
import 'package:odc_mobile_template/business/models/user/putPassword.dart';
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

  
  @override
  Future<Profile?> getProfileTutor(String token) async {
    try {
      var url = '$baseUrl/tutors/get';
      var response = await httpUtils.getData(url, token: token);
      if (response == null) return null;
      var data = json.decode(response);
      if (data['data'] == null) {
        print('Structure de réponse inattendue: $data');
        return null;
      }
      print(Profile.fromJson(data['data']));
      return Profile.fromJson(data['data']);
    } catch (e) {
      print('Erreur getProfileTutor: $e');
      return null;
    }
  }

  @override
  Future<void> updateUserPassword(PutPassword data,String token) async{
    var url = '$baseUrl/users/update-password';
    var body = data.toJson();
    var response = await httpUtils.putData(url,token: token,body: body);
    return;
  }

  @override
  Future<void> savePreferences(List<int> categoryIds,String token) async{
    final url = '$baseUrl/preferences';
    final body = {
      'category_ids': categoryIds,
    };
    final response = await httpUtils.postData(url,token: token,body: body);
    return;
  }

}

void main() async {
  //test register
  var service = UserNetworkServiceImpl(
    baseUrl: "http://10.66.10.71:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  var auth = Authentication(email: "tutor@gmail.com", password: "azertyuiop");
  var user = await UserNetworkServiceImpl(baseUrl: "http://10.66.10.71:8000/api", httpUtils: LocalHttpUtils()).seConnecter(auth);
  var userPassword = PutPassword(old_password: "password", new_password: "azertyuiop", password_confirmation: "azertyuiop");
  var category_ids = [69,70,71];
  await service.savePreferences(category_ids,user?.token ?? "");

}
