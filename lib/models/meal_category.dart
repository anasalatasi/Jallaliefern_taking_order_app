import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'meal_category.g.dart';

@JsonSerializable(explicitToJson: true)
class MealCategory {
  MealCategory({this.image,required this.name,this.description,required this.priority,required this.hidden});
  final String? image;
  final String name;
  final String? description;
  final int priority;
  final bool hidden;

  factory MealCategory.fromRawJson(String str) =>
      MealCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MealCategory.fromJson(Map<String,dynamic> json) => _$MealCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$MealCategoryToJson(this);
}