import 'dart:convert';
import 'dart:io';

import 'package:jallaliefern_taking_orders_app/models/order.dart';
import 'package:jallaliefern_taking_orders_app/services/login_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

import 'secure_storage_service.dart';
import 'package:http/http.dart' as http;
import '../utils/exceptions.dart';

class ApiService {
  Future<String> _getRequest(String endpoint) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String fullUrl = "$apiUrl$endpoint";
    final client = http.Client();
    final response = await client.get(Uri.parse(fullUrl));
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 200) {
      return Future.value(response.body);
    } else
      throw Exception('Unknown Error');
  }

  // returns raw json
  Future<String> _getAuthRequest(String endpoint) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String jwtToken = await locator<LoginService>().token.access;
    String fullUrl = "$apiUrl$endpoint";
    final client = http.Client();
    final response = await client.get(Uri.parse(fullUrl),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $jwtToken'});
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 200) {
      return Future.value(response.body);
    } else
      throw Exception('Unknown Error');
  }

  Future<String> getRestaurantInfo() async =>
      await _getRequest('settings/restaurant/1/');

  Future<List<Order>> getNewOrders() async {
    try {
      final rawData = await _getAuthRequest('orders/order/');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      return List<Order>.empty();
    }
  }
}
