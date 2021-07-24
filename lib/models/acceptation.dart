import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'acceptation.g.dart';

@JsonSerializable(explicitToJson: true)
class Acceptation {
  Acceptation({required this.accepted,this.eta});
  final bool accepted;
  final String? eta;

  factory Acceptation.fromRawJson(String str) =>
      Acceptation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Acceptation.fromJson(Map<String,dynamic> json) => _$AcceptationFromJson(json);
  Map<String, dynamic> toJson() => _$AcceptationToJson(this);
}