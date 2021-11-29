// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
      id: json['id'] as int,
      count: json['count'] as int?,
      slug: json['slug'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      type: json['type'] as int,
      status: json['status'] as int,
      dineTable: json['dine_table'] as int?,
      delivery: json['delivery'] == null
          ? null
          : Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      itemss: json['items'] == null
          ? null
          : (json['items'] as List<dynamic>)
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList(),
      giftChoices: json['gift_choices'] == null
          ? null
          : (json['gift_choices'] as List<dynamic>)
              .map((e) => OrderGift.fromJson(e as Map<String, dynamic>))
              .toList(),
      serveTime: json['serve_time'] as String?,
      createdAt: json['created_at'] as String,
      recieveEmail: json['recieve_email'] as bool,
      totalPrice: double.parse(json['total_price']),
      beforePrice: double.parse(json['before_price']),
      deliveryPrice: double.parse(json['delivery_price']),
      notes: json['notes'] as String?,
      isNew: json['is_new'] as bool,
      isPreorder: json['is_preorder'] as bool);
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
      'slug': instance.slug,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'type': instance.type,
      'status': instance.status,
      'dine_table': instance.dineTable,
      'delivery': instance.delivery?.toJson(),
      'payment': instance.payment.toJson(),
      'items': instance.itemss?.map((e) => e.toJson()).toList(),
      'gift_choices': instance.giftChoices?.map((e) => e.toJson()).toList(),
      'serve_time': instance.serveTime,
      'created_at': instance.createdAt,
      'recieve_email': instance.recieveEmail,
      'total_price': instance.totalPrice,
      'before_price': instance.beforePrice,
      'delivery_price': instance.deliveryPrice,
      'notes': instance.notes,
      'is_new': instance.isNew,
      'is_preorder': instance.isPreorder
    };
