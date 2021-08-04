import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/models/section.dart';
import 'package:jallaliefern_taking_orders_app/models/zone.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:json_annotation/json_annotation.dart';
part 'delivery.g.dart';

@JsonSerializable(explicitToJson: true)
class Delivery {
  Delivery(
      {required this.address,
      required this.zoneId,
      this.sectionId,
      this.buildingNo});
  final String address;
  @JsonKey(name: 'zone')
  final int zoneId;
  @JsonKey(ignore: true)
  Zone? zone;
  @JsonKey(name: 'section')
  final int? sectionId;
  @JsonKey(ignore: true)
  Section? section;
  @JsonKey(name: 'building_no')
  final String? buildingNo;

  Future<Zone?> getZone() async {
    if (zone == null) {
      zone = await locator<ApiService>().getZone(zoneId);
    }
    return zone;
  }

  Future<Section?> getSection() async {
    if (sectionId == null) return null;
    if (section == null) {
      section = await locator<ApiService>().getSection(sectionId!);
    }
    return section;
  }

  factory Delivery.fromRawJson(String str) =>
      Delivery.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryToJson(this);
}
