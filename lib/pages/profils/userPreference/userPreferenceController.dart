import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/category/categoryNetworkService.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/profils/userPreference/userPreferenceState.dart';

class UserPreferenceController extends StateNotifier<UserPreferenceState>{
  var categoryService = getIt.get<CategoryNetworkService>();
  var userService = getIt.get<UserNetworkService>();
  UserPreferenceController() : super(UserPreferenceState()){
    _init();
  }

  Future<void> _init() async {
    if (state.categories == null || state.categories!.isEmpty) {
      await getCategories();
    }
  }

  Future<void> getCategories() async{
    state = state.copyWith(isLoading: true);
    try{
      var categories = await categoryService.getCategories();
      state = state.copyWith(categories: categories,isLoading: false);
    }catch(e){
      state = state.copyWith(isLoading: false,errorMsg: e.toString());
    }
  }

  Future<bool> savePreference(List<int> data,String token) async{
    state = state.copyWith(isLoading: true);
    try{
      await userService.savePreferences(data, token);
      state = state.copyWith(isLoading: false);
      return true;
    }catch(e){
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final userPreferenceControllerProvider = StateNotifierProvider<UserPreferenceController,UserPreferenceState>((ref) => UserPreferenceController());