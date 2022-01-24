import 'dart:convert';

import 'delivery.dart';

class DriverOrder {
  int? id;
  String? slug;
  String? firstName;
  String? lastName;
  String? endedAt;
  Delivery? delivery;
  double? totalPrice;
  double? deliveryPrice;
  int? paymentType;
  DriverOrder({
    this.id,
    this.slug,
    this.firstName,
    this.lastName,
    this.delivery,
    this.totalPrice,
    this.deliveryPrice,
    this.paymentType,
    this.endedAt,
  });

  DriverOrder copyWith({
    int? id,
    String? slug,
    String? firstName,
    String? lastName,
    Delivery? delivery,
    double? totalPrice,
    double? deliveryPrice,
    int? paymentType,
    String? endedAt,
  }) {
    return DriverOrder(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        delivery: delivery ?? this.delivery,
        totalPrice: totalPrice ?? this.totalPrice,
        deliveryPrice: deliveryPrice ?? this.deliveryPrice,
        paymentType: paymentType ?? this.paymentType,
        endedAt: endedAt ?? this.endedAt);
  }

  factory DriverOrder.fromMap(Map<String, dynamic> map) {
    return DriverOrder(
      id: map['id']?.toInt(),
      slug: map['slug'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      delivery:
          map['delivery'] != null ? Delivery.fromJson(map['delivery']) : null,
      totalPrice:
          map['total_price'] != null ? double.parse(map['total_price']) : null,
      deliveryPrice: map['delivery_price'] != null
          ? double.parse(map['delivery_price'])
          : null,
      paymentType: map['payment_type']?.toInt(),
      endedAt: map['ended_at'],
    );
  }

  factory DriverOrder.fromJson(String source) =>
      DriverOrder.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DriverOrder(id: $id, slug: $slug, firstName: $firstName, lastName: $lastName, delivery: $delivery, totalPrice: $totalPrice, deliveryPrice: $deliveryPrice, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DriverOrder &&
        other.id == id &&
        other.slug == slug &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.delivery == delivery &&
        other.totalPrice == totalPrice &&
        other.deliveryPrice == deliveryPrice &&
        other.paymentType == paymentType &&
        other.endedAt == endedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        slug.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        delivery.hashCode ^
        totalPrice.hashCode ^
        deliveryPrice.hashCode ^
        paymentType.hashCode ^
        endedAt.hashCode;
  }
}
