import 'package:odc_mobile_template/business/models/user/profile.dart';

class EditProfileState{
  final bool isLoading;
  final String? errorMsg;
  final Profile? profile;

  EditProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMsg
  });

  EditProfileState copyWith({
    final bool? isLoading,
    final String? errorMsg,
    final Profile? profile
  }){
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMsg: errorMsg ?? this.errorMsg
    );
  }
}