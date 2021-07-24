import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'zone.g.dart';

@JsonSerializable(explicitToJson: true)
class Zone {
  Zone({required this.name});
  final String name;

  factory Zone.fromRawJson(String str) =>
      Zone.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Zone.fromJson(Map<String,dynamic> json) => _$ZoneFromJson(json);
  Map<String, dynamic> toJson() => _$ZoneToJson(this);
}