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
    sectionName: json['section_name'] as String?,
    zipcode: json['zipcode'] as String,
    buildingNo: json['building_no'] as int?,
  );
}

Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
      'address': instance.address,
      'zone': instance.zoneId,
      'section': instance.sectionId,
      'section_name': instance.sectionName,
      'zipcode': instance.zipcode,
      'building_no': instance.buildingNo,
    };
