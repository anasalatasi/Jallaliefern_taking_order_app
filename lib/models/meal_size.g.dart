// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_size.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealSize _$MealSizeFromJson(Map<String, dynamic> json) {
  return MealSize(
    name: json['name'] as String,
    price: json['price'] as String?,
  );
}

Map<String, dynamic> _$MealSizeToJson(MealSize instance) => <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
    };
