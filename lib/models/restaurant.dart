import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

class Restaurant {
  int? id;
  String? name;
  String? country;
  String? city;
  String? street;
  String? logo;
  String? phone1;
  String? phone2;
  String? currency;
  Restaurant.empty();
  Restaurant({
    required this.id,
    required this.name,
    required this.logo,
    this.city,
    this.country,
    this.street,
    this.phone1,
    this.phone2,
    this.currency,
  });

  Future<void> init() async {
    try {
      final rawdata = await locator<ApiService>().getRestaurantInfo();
      Restaurant rest = Restaurant.fromRawJson(rawdata);
      id = rest.id;
      name = rest.name;
      logo = rest.logo;
      country = rest.country;
      city = rest.city;
      street = rest.street;
      phone1 = rest.phone1;
      phone2 = rest.phone2;
      currency = rest.currency;
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  factory Restaurant.fromRawJson(String str) =>
      Restaurant.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(id: json['id'], name: json['name'], logo: json['logo']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo': logo,
        'city': city,
        'street': street,
        'country': country,
        'phone1': phone1,
        'phone2': phone2,
        'currency': currency,
      };
}
