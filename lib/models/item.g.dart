// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    mealId: json['meal'] as int,
    sizeId: json['size'] as int?,
    addons: (json['addons'] as List<dynamic>?)
        ?.map((e) => ItemAddon.fromJson(e as Map<String, dynamic>))
        .toList(),
    quantity: json['quantity'] as int,
    totalPrice: double.parse(json['total_price']),
    mealObject: Meal.fromJson(json['meal_object'] as Map<String, dynamic>),
    sizeObject: json['size_object'] == null
        ? null
        : MealSize.fromJson(json['size_object'] as Map<String, dynamic>),
    notes: json['notes'] as String,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'meal': instance.mealId,
      'meal_object': instance.mealObject.toJson(),
      'size_object': instance.sizeObject?.toJson(),
      'size': instance.sizeId,
      'addons': instance.addons?.map((e) => e.toJson()).toList(),
      'quantity': instance.quantity,
      'total_price': instance.totalPrice,
      'notes': instance.notes,
    };
