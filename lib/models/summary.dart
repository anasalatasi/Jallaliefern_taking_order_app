import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:jallaliefern_taking_orders_app/models/driver_order.dart';

class Summary {
  List<DriverOrder>? orders;
  double? sumCash;
  double? sumPaypal;
  double? sumTotal;
  Summary({
    this.orders,
    this.sumCash,
    this.sumPaypal,
    this.sumTotal,
  });

  Summary copyWith({
    List<DriverOrder>? orders,
    double? sumCash,
    double? sumPaypal,
    double? sumTotal,
  }) {
    return Summary(
      orders: orders ?? this.orders,
      sumCash: sumCash ?? this.sumCash,
      sumPaypal: sumPaypal ?? this.sumPaypal,
      sumTotal: sumTotal ?? this.sumTotal,
    );
  }

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      orders: map['orders'] != null
          ? List<DriverOrder>.from(
              map['orders']?.map((x) => DriverOrder.fromMap(x)))
          : null,
      sumCash: map['sum_cash']?.toDouble(),
      sumPaypal: map['sum_paypal']?.toDouble(),
      sumTotal: map['sum_total']?.toDouble(),
    );
  }

  factory Summary.fromJson(String source) =>
      Summary.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Summary(orders: $orders, sum_cash: $sumCash, sum_paypal: $sumPaypal, sum_total: $sumTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Summary &&
        listEquals(other.orders, orders) &&
        other.sumCash == sumCash &&
        other.sumPaypal == sumPaypal &&
        other.sumTotal == sumTotal;
  }

  @override
  int get hashCode {
    return orders.hashCode ^
        sumCash.hashCode ^
        sumPaypal.hashCode ^
        sumTotal.hashCode;
  }
}
