import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'item_addon.dart';
import 'meal.dart';
import 'meal_size.dart';
part 'item.g.dart';

@JsonSerializable(explicitToJson: true)
class Item {
  Item(
      {required this.mealId,
      this.sizeId,
      this.addons,
      required this.quantity,
      required this.totalPrice,
      required this.mealObject,
      this.sizeObject,
      this.notes});
  @JsonKey(name: 'meal')
  final int mealId;
  @JsonKey(name: 'meal_object')
  final Meal mealObject;
  @JsonKey(name: 'size_object')
  final MealSize? sizeObject;
  @JsonKey(ignore: true)
  Meal? meal;
  @JsonKey(ignore: true)
  MealSize? size;
  @JsonKey(name: 'size')
  final int? sizeId;
  final List<ItemAddon>? addons;
  final int quantity;
  @JsonKey(name: 'total_price')
  final double totalPrice;
  final String? notes;

  Future<Meal?> getMeal() async {
    if (meal == null) {
      meal = await locator<ApiService>().getMeal(mealId);
    }
    return meal;
  }

  Future<MealSize?> getMealSize() async {
    if (sizeId == null)
      return null;
    else if (size == null) {
      size = await locator<ApiService>().getMealSize(sizeId!);
    }
    return size;
  }

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
