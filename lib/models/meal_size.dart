import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'meal_size.g.dart';

@JsonSerializable(explicitToJson: true)
class MealSize {
  MealSize({required this.name});
  final String name;

  factory MealSize.fromRawJson(String str) =>
      MealSize.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MealSize.fromJson(Map<String,dynamic> json) => _$MealSizeFromJson(json);
  Map<String, dynamic> toJson() => _$MealSizeToJson(this);
}