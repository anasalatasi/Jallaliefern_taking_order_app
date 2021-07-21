// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Addon _$AddonFromJson(Map<String, dynamic> json) {
  return Addon(
    id: json['id'] as int,
    name: json['name'] as String,
    price: json['price'] as String,
    groupId: json['group'] as int,
  );
}

Map<String, dynamic> _$AddonToJson(Addon instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'group': instance.groupId,
    };
