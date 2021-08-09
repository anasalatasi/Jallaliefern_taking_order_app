import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'delivery.dart';
import 'payment.dart';
import 'item.dart';
part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  Order(
      {required this.id,
      required this.slug,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.type,
      required this.status,
      this.delivery,
      required this.payment,
      required this.items,
      this.serveTime,
      required this.createdAt,
      required this.recieveEmail,
      required this.totalPrice,
      this.notes});

  final int id;
  final String slug;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String phone;
  final int type;
  final int status;
  final Delivery? delivery;
  final Payment payment;
  final List<Item> items;
  @JsonKey(name: 'serve_time')
  final String? serveTime;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'recieve_email')
  final bool recieveEmail;
  @JsonKey(name: 'total_price')
  final double totalPrice;
  final String? notes;

  get serveDateTime {
    if (serveTime == null) return null;
    return DateTime.parse(serveTime!);
  }

  factory Order.fromRawJson(String str) => Order.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  String getType() {
    if (this.type == 1)
      return "Delivery";
    else if (this.type == 2) return "Pickup";
    return "Unknown";
  }
}
