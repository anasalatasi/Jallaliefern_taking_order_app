// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) {
  return Meal(
    image: json['image'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    priority: json['priority'] as int,
    hidden: json['hidden'] as bool,
    categoryId: json['category'] as int,
    price: json['price'] as String?,
  );
}

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
      'image': instance.image,
      'name': instance.name,
      'description': instance.description,
      'priority': instance.priority,
      'hidden': instance.hidden,
      'category': instance.categoryId,
      'price': instance.price,
    };
