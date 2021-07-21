import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'delivery.g.dart';

@JsonSerializable(explicitToJson: true)
class Delivery {
  Delivery(
      {required this.address,
      required this.zoneId,
      this.sectionId,
      this.sectionName,
      required this.zipcode,
      this.buildingNo});
  final String address;
  @JsonKey(name: 'zone')
  final int zoneId;
  @JsonKey(name: 'section')
  final int? sectionId;
  @JsonKey(name: 'section_name')
  final String? sectionName;
  final String zipcode;
  @JsonKey(name: 'building_no')
  final int? buildingNo;

  factory Delivery.fromRawJson(String str) =>
      Delivery.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryToJson(this);
}
