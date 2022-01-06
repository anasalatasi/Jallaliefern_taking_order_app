import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:jallaliefern_taking_orders_app/models/driver_order.dart';
import 'package:jallaliefern_taking_orders_app/models/order.dart';

class Driver {
  int? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  List<DriverOrder>? orders;
  double? sumCash;
  double? sumPaypal;
  double? sumTotal;
  Driver({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.orders,
    this.sumCash,
    this.sumPaypal,
    this.sumTotal,
  });

  Driver copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    List<DriverOrder>? orders,
    double? sumCash,
    double? sumPaypal,
    double? sumTotal,
  }) {
    return Driver(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      orders: orders ?? this.orders,
      sumCash: sumCash ?? this.sumCash,
      sumPaypal: sumPaypal ?? this.sumPaypal,
      sumTotal: sumTotal ?? this.sumTotal,
    );
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id']?.toInt(),
      username: map['username'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phoneNumber: map['phone_number'],
      orders: map['orders'] != null
          ? List<DriverOrder>.from(
              map['orders']?.map((x) => DriverOrder.fromMap(x)))
          : null,
      sumCash: map['sum_cash'] != null ? map['sum_cash'] : null,
      sumPaypal: map['sum_paypal'] != null ? map['sum_paypal'] : null,
      sumTotal: map['sum_total'] != null
          ? map['sum_total'] != 0
              ? map['sum_total']
              : 0
          : null,
    );
  }

  factory Driver.fromJson(String source) => Driver.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Driver(id: $id, username: $username, email: $email, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, orders: $orders, sumCash: $sumCash, sumPaypal: $sumPaypal, sumTotal: $sumTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Driver &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        listEquals(other.orders, orders) &&
        other.sumCash == sumCash &&
        other.sumPaypal == sumPaypal &&
        other.sumTotal == sumTotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        orders.hashCode ^
        sumCash.hashCode ^
        sumPaypal.hashCode ^
        sumTotal.hashCode;
  }
}
