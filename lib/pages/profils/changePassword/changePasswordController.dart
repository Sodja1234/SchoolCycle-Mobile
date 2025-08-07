import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/putPassword.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/profils/changePassword/changePasswordState.dart';

class ChangePasswordController extends StateNotifier<ChangePasswordState>{
  var userService = getIt.get<UserNetworkService>();
  ChangePasswordController() : super(ChangePasswordState());

  Future<bool> updatePassword(PutPassword data,String token) async{
    state = state.copyWith(isLoading: true);
    try{
      await userService.updateUserPassword(data, token);
      state = state.copyWith(isLoading: false);
      return true;
    }catch(e){
      state = state.copyWith(isLoading: false,erroMsg: e.toString());
      return false;
    }
  }
}

final changePasswordProvider = StateNotifierProvider<ChangePasswordController,ChangePasswordState>((ref) => ChangePasswordController());