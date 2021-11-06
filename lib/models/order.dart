import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/service_locator.dart';
import 'delivery.dart';
import 'ordergift.dart';
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
      this.dineTable,
      required this.payment,
      this.serveTime,
      this.itemss,
      this.giftChoices,
      required this.createdAt,
      required this.recieveEmail,
      required this.totalPrice,
      this.notes,
      required this.isNew,
      required this.isPreorder,
      this.deliveryPrice});

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
  @JsonKey(name: 'dine_table')
  final int? dineTable;
  final Delivery? delivery;
  final Payment payment;
  @JsonKey(name: 'items')
  List<Item>? itemss;
  @JsonKey(name: 'gift_choices')
  List<OrderGift>? giftChoices;
  @JsonKey(name: 'serve_time')
  final String? serveTime;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'recieve_email')
  final bool recieveEmail;
  @JsonKey(name: 'total_price')
  final double totalPrice;
  final String? notes;
  @JsonKey(name: 'is_new')
  final bool isNew;
  @JsonKey(name: 'is_preorder')
  final bool isPreorder;
  @JsonKey(name: 'delivery_price')
  final double? deliveryPrice;
  get items async {
    if (itemss != null) return itemss;
    itemss = (await locator<ApiService>().getOrder(id))?.itemss;
    return itemss;
  }

  get giftChoicess async {
    if (giftChoices != null) return giftChoices;
    giftChoices = (await locator<ApiService>().getOrder(id))?.giftChoices;
    return giftChoices;
  }

  get dineTableName async {
    if (dineTable == null) return null;
    return (await locator<ApiService>().getTableName(dineTable!));
  }

  get serveDateTime {
    if (serveTime == null) return null;
    return DateTime.parse(serveTime!).toLocal();
  }

  factory Order.fromRawJson(String str) => Order.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  String getType() {
    if (this.type == 1)
      return "Liefern";
    else if (this.type == 2)
      return "Abholen";
    else if (this.type == 3) return "DineIn";
    return "Unknown";
  }
}
