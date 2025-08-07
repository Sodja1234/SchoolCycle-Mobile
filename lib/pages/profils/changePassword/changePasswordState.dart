import 'package:odc_mobile_template/business/models/user/profile.dart';

class ChangePasswordState{
  final bool isLoading;
  final String? erroMsg;

  ChangePasswordState({
    this.isLoading = false,
    this.erroMsg
  });

  ChangePasswordState copyWith({
    final bool? isLoading,
    final String? erroMsg,
  }){
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      erroMsg: erroMsg ?? this.erroMsg,
    );
  }
}