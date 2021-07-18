import 'dart:convert';

import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

class Restaurant {
  int? id;
  String? name;
  String? logo;

  Restaurant.empty();
  Restaurant({required this.id, required this.name, required this.logo});

  Future<void> init() async {
    try {
      final rawdata = await locator<ApiService>().getRestaurantInfo();
      Restaurant rest = Restaurant.fromRawJson(rawdata);
      id = rest.id;
      name = rest.name;
      logo = rest.logo;
    } catch(e) {
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
      };
}
