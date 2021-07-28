import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:json_annotation/json_annotation.dart';

import 'addon.dart';
part 'item_addon.g.dart';

@JsonSerializable(explicitToJson: true)
class ItemAddon {
  ItemAddon({required this.addonId,this.quantity = 1,required this.totalPrice});
  @JsonKey(name:'addon')
  final int addonId;
  @JsonKey(ignore: true)
  Addon? addon;
  final int quantity;
  @JsonKey(name:'total_price')
  final double totalPrice;

  Future<Addon?> getAddon() async {
    if (addon == null) {
      addon = await locator<ApiService>().getAddon(addonId);
    }
    return addon;
  }

  factory ItemAddon.fromRawJson(String str) =>
      ItemAddon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ItemAddon.fromJson(Map<String,dynamic> json) => _$ItemAddonFromJson(json);
  Map<String, dynamic> toJson() => _$ItemAddonToJson(this);
}