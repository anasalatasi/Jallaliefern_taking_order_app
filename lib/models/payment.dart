import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'payment.g.dart';

@JsonSerializable(explicitToJson: true)
class Payment {
  Payment({required this.type, this.payed, this.amountPayed});
  final int type;
  final bool? payed;
  @JsonKey(name: 'amount_payed')
  final double? amountPayed;
  factory Payment.fromRawJson(String str) => Payment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
