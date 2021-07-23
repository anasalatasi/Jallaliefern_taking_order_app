import 'dart:convert';
import 'dart:io';

import 'package:jallaliefern_taking_orders_app/models/meal.dart';
import 'package:jallaliefern_taking_orders_app/models/meal_category.dart';
import 'package:jallaliefern_taking_orders_app/models/meal_size.dart';
import 'package:jallaliefern_taking_orders_app/models/order.dart';
import 'package:jallaliefern_taking_orders_app/services/login_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info/device_info.dart';

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

  Future<String> _postAuthRequest(String endpoint, String rawData) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String jwtToken = await locator<LoginService>().token.access;
    String fullUrl = "$apiUrl$endpoint";
    final client = http.Client();
    final response = await client.post(Uri.parse(fullUrl),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $jwtToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: rawData);
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 201 || response.statusCode == 200) {
      return Future.value(response.body);
    } else
      throw Exception('Unknown Error');
  }

  Future<void> registerDevice() async {
    final registirationId = await FirebaseMessaging.instance.getToken();
    late final deviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
    Map<String, dynamic> data = {
      'registration_id': registirationId,
      'device_id': deviceId,
      'type': Platform.isAndroid ? 'android' : 'ios'
    };
    await _postAuthRequest('fcm_devices', json.encode(data));
  }

  Future<String> getRestaurantInfo() async =>
      await _getRequest('settings/restaurant/1/');

  Future<List<Order>> getNewOrders() async {
    try {
      final rawData = await _getAuthRequest('orders/order/?filters=(status=1)');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      return List<Order>.empty();
    }
  }

  Future<Meal?> getMeal(int id) async {
    try{
      final rawData = await _getAuthRequest('menu/meal/$id/');
      return Meal.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }

  Future<MealSize?> getMealSize(int id) async {
    try{
      final rawData = await _getAuthRequest('menu/meal_size/$id/');
      return MealSize.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }

  Future<MealCategory?> getCategory(int id) async {
    try{
      final rawData = await _getAuthRequest('menu/meal_category/$id/');
      return MealCategory.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }
}
