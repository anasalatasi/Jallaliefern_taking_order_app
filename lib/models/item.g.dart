// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    mealId: json['meal'] as int,
    size: json['size'] as int?,
    addons: (json['addons'] as List<dynamic>?)
        ?.map((e) => Addon.fromJson(e as Map<String, dynamic>))
        .toList(),
    quantity: json['quantity'] as int,
    totalPrice: json['total_price'] as String,
    notes: json['notes'] as String?,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'meal': instance.mealId,
      'size': instance.size,
      'addons': instance.addons?.map((e) => e.toJson()).toList(),
      'quantity': instance.quantity,
      'total_price': instance.totalPrice,
      'notes': instance.notes,
    };