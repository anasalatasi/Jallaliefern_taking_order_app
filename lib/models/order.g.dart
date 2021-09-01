// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
      id: json['id'] as int,
      slug: json['slug'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      type: json['type'] as int,
      status: json['status'] as int,
      delivery: json['delivery'] == null
          ? null
          : Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      serveTime: json['serve_time'] as String?,
      createdAt: json['created_at'] as String,
      recieveEmail: json['recieve_email'] as bool,
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      isNew: json['is_new'] as bool);
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'type': instance.type,
      'status': instance.status,
      'delivery': instance.delivery?.toJson(),
      'payment': instance.payment.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'serve_time': instance.serveTime,
      'created_at': instance.createdAt,
      'recieve_email': instance.recieveEmail,
      'total_price': instance.totalPrice,
      'notes': instance.notes,
      'is_new': instance.isNew
    };
