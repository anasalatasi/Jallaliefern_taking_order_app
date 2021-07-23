// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealCategory _$MealCategoryFromJson(Map<String, dynamic> json) {
  return MealCategory(
    image: json['image'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    priority: json['priority'] as int,
    hidden: json['hidden'] as bool,
  );
}

Map<String, dynamic> _$MealCategoryToJson(MealCategory instance) =>
    <String, dynamic>{
      'image': instance.image,
      'name': instance.name,
      'description': instance.description,
      'priority': instance.priority,
      'hidden': instance.hidden,
    };
