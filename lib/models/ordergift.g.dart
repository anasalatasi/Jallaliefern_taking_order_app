// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordergift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderGift _$OrderGiftFromJson(Map<String, dynamic> json) {
  return OrderGift(
    id: json['id'] as int,
    image: json['image'] as String,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$OrderGiftToJson(OrderGift instance) => <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'description': instance.description,
    };
