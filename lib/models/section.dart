import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'section.g.dart';

@JsonSerializable(explicitToJson: true)
class Section {
  Section({required this.name,required this.zipCode});
  final String name;
  @JsonKey(name: 'zip_code')
  final String zipCode;

  factory Section.fromRawJson(String str) =>
      Section.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Section.fromJson(Map<String,dynamic> json) => _$SectionFromJson(json);
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}