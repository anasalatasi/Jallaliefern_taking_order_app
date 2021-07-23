import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:json_annotation/json_annotation.dart';

import 'meal_category.dart';
part 'meal.g.dart';

@JsonSerializable(explicitToJson: true)
class Meal {
  Meal({this.image,required this.name,this.description,required this.priority,required this.hidden,required this.categoryId});
  final String? image;
  final String name;
  final String? description;
  final int priority;
  final bool hidden;
  @JsonKey(name: 'category')
  final int categoryId;
  @JsonKey(ignore: true)
  MealCategory? category;

  Future<String> getCategoryName() async {
    if (category == null) {
      category = await locator<ApiService>().getCategory(categoryId);
      if (category == null) return "";
    }
    return category!.name;
  }

  factory Meal.fromRawJson(String str) =>
      Meal.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Meal.fromJson(Map<String,dynamic> json) => _$MealFromJson(json);
  Map<String, dynamic> toJson() => _$MealToJson(this);
}