// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_addon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemAddon _$ItemAddonFromJson(Map<String, dynamic> json) {
  return ItemAddon(
    addonId: json['addon'] as int,
    totalPrice: (json['total_price'] as num).toDouble(),
  );
}

Map<String, dynamic> _$ItemAddonToJson(ItemAddon instance) => <String, dynamic>{
      'addon': instance.addonId,
      'total_price': instance.totalPrice,
    };
