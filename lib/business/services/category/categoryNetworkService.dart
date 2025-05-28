import 'package:odc_mobile_template/business/models/category/category.dart';

abstract class CategoryNetworkService{

  // la méthode pour récuperer la liste des categories
  Future<List<Category>> getCategories();
}