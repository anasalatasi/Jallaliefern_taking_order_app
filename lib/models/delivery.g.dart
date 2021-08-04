// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Delivery _$DeliveryFromJson(Map<String, dynamic> json) {
  return Delivery(
    address: json['address'] as String,
    zoneId: json['zone'] as int,
    sectionId: json['section'] as int?,
    buildingNo: json['building_no'] as String?,
  );
}

Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
      'address': instance.address,
      'zone': instance.zoneId,
      'section': instance.sectionId,
      'building_no': instance.buildingNo,
    };
