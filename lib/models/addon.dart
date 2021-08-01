import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'addon.g.dart';

@JsonSerializable(explicitToJson: true)
class Addon {
  Addon({required this.id,required this.name,required this.groupId});
  final int id;
  final String name;
  @JsonKey(name:'group')
  final int groupId;

  factory Addon.fromRawJson(String str) =>
      Addon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Addon.fromJson(Map<String,dynamic> json) => _$AddonFromJson(json);
  Map<String, dynamic> toJson() => _$AddonToJson(this);
}