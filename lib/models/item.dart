import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'addon.dart';
part 'item.g.dart';
@JsonSerializable(explicitToJson: true)
class Item {
  Item({required this.mealId,this.size,this.addons,required this.quantity,required this.totalPrice,this.notes});
  @JsonKey(name: 'meal')
  final int mealId;
  final int? size;
  final List<Addon>? addons;
  final int quantity;
  @JsonKey(name: 'total_price')
  final double totalPrice;
  final String? notes;

  factory Item.fromRawJson(String str) =>
      Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String,dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}