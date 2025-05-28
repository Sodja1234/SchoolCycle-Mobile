import 'dart:convert';

import 'package:odc_mobile_template/business/models/category/category.dart';
import 'package:odc_mobile_template/business/services/category/categoryNetworkService.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';

import '../../utils/http/HttpUtils.dart';

class CategoryNetworkServiceImp implements CategoryNetworkService{
  final String baseUrl;
  final HttpUtils httpUtils;

  // Le constructeur de la classe
  CategoryNetworkServiceImp({required this.baseUrl,required this.httpUtils});

  @override
  Future<List<Category>> getCategories() async{
    var url = '$baseUrl/categories';
    var response = await httpUtils.getData(url);
    var data = jsonDecode(response);
    var categories = data.map<Category>((e)=>Category.fromJson(e)).toList();
    return categories;
  }
}


void main() async{
  var test = CategoryNetworkServiceImp(baseUrl: "http://127.0.0.1:8000/api", httpUtils: LocalHttpUtils());
  var categories = await test.getCategories();
  for(var i in categories){
    print('------------------------------------');
    print("nom : ${i.name}");
    print("description : ${i.description}");
  }
}