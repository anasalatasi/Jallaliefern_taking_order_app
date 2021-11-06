import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'ordergift.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderGift {
  OrderGift({
    required this.id,
    this.image,
    this.description,
  });
  final int id;
  final String? image;
  final String? description;

  factory OrderGift.fromRawJson(String str) =>
      OrderGift.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderGift.fromJson(Map<String, dynamic> json) =>
      _$OrderGiftFromJson(json);
  Map<String, dynamic> toJson() => _$OrderGiftToJson(this);
}
