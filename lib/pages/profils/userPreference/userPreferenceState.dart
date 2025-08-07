
import '../../../business/models/category/category.dart';

class UserPreferenceState{
  final bool isLoading;
  final String? errorMsg;
  final List<Category>? categories;

  UserPreferenceState({
    this.isLoading = false,
    this.categories,
    this.errorMsg
  });


  UserPreferenceState copyWith({
    bool? isLoading,
    String? errorMsg,
    List<Category>? categories
  }){
    return UserPreferenceState(
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
      categories: categories ?? this.categories
    );
  }
}