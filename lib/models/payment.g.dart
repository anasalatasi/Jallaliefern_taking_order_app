// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return Payment(
    type: json['type'] as int,
    payed: json['payed'] as bool?,
    amountPayed: json['amount_payed'] != null
        ? double.parse(json['amount_payed'])
        : null,
  );
}

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'type': instance.type,
      'payed': instance.payed,
      'amount_payed': instance.amountPayed,
    };
