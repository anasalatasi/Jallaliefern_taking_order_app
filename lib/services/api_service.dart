import 'dart:convert';
import 'dart:io';

import 'package:http/retry.dart';
import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/models/acceptation.dart';
import 'package:jallaliefern_taking_orders_app/models/addon.dart';
import 'package:jallaliefern_taking_orders_app/models/meal.dart';
import 'package:jallaliefern_taking_orders_app/models/meal_category.dart';
import 'package:jallaliefern_taking_orders_app/models/meal_size.dart';
import 'package:jallaliefern_taking_orders_app/models/order.dart';
import 'package:jallaliefern_taking_orders_app/models/section.dart';
import 'package:jallaliefern_taking_orders_app/models/table_reservation.dart';
import 'package:jallaliefern_taking_orders_app/models/zone.dart';
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
    final client = RetryClient(http.Client());
    final response = await client.get(Uri.parse(fullUrl));
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 200) {
      return Future.value(Utf8Decoder().convert(response.body.codeUnits));
    } else
      throw Exception('Unknown Error');
  }

  Future<String> _deleteAuthRequest(String endpoint) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String jwtToken = await locator<SecureStorageService>().accessToken;
    String fullUrl = "$apiUrl$endpoint";
    final client = RetryClient(http.Client());
    final response = await client.delete(Uri.parse(fullUrl),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $jwtToken'});
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 200) {
      return Future.value(Utf8Decoder().convert(response.body.codeUnits));
    } else
      throw Exception('Unknown Error');
  }

  // returns raw json
  Future<String> _getAuthRequest(String endpoint) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String jwtToken = await locator<SecureStorageService>().accessToken;
    String fullUrl = "$apiUrl$endpoint";
    final client = RetryClient(http.Client());
    final response = await client.get(Uri.parse(fullUrl),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $jwtToken'});
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 200) {
      return Future.value(Utf8Decoder().convert(response.body.codeUnits));
    } else
      throw Exception('Unknown Error');
  }

  Future<String> _postAuthRequest(String endpoint, String rawData) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String jwtToken = await locator<SecureStorageService>().accessToken;
    String fullUrl = "$apiUrl$endpoint";
    final client = RetryClient(http.Client());
    final response = await client.post(Uri.parse(fullUrl),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $jwtToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: rawData);
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 201 || response.statusCode == 200) {
      return Future.value(Utf8Decoder().convert(response.body.codeUnits));
    } else
      throw Exception('Unknown Error');
  }

  Future<String> _patchAuthRequest(String endpoint, String rawData) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String jwtToken = await locator<SecureStorageService>().accessToken;
    String fullUrl = "$apiUrl$endpoint";
    final client = RetryClient(http.Client());
    final response = await client.patch(Uri.parse(fullUrl),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $jwtToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: rawData);
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 201 || response.statusCode == 200) {
      return Future.value(Utf8Decoder().convert(response.body.codeUnits));
    } else
      throw Exception('Unknown Error');
  }

  Future<String> _postRequest(String endpoint, String rawData) async {
    String apiUrl = await locator<SecureStorageService>().apiUrl;
    String fullUrl = "$apiUrl$endpoint";
    final client = RetryClient(http.Client());
    final response = await client.post(Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: rawData);
    if (response.statusCode == 401)
      throw UnauthorizedException();
    else if (response.statusCode == 201 || response.statusCode == 200) {
      return Future.value(Utf8Decoder().convert(response.body.codeUnits));
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

  Future<List<Order>> getPreOrders() async {
    try {
      String filters =
          "(is_preorder=true) & (serve_time__gte=${(DateTime(DateTime.now().subtract(Duration(days: 1)).year, DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day)).toUtc().toIso8601String()})";
      filters = Uri(queryParameters: {
        'filters': filters,
        'lite': '1',
        'ordering': "serve_time"
      }).query;
      final rawData = await _getAuthRequest('orders/order/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      print(e.toString());
      return List<Order>.empty();
    }
  }

  Future<List<Order>> getNewOrders() async {
    try {
      String filters =
          "(status=1) & ((serve_time__lte=${DateTime.now().add(Duration(hours: 1)).toUtc().toIso8601String()}) | (status=1&created_at__gte=${(DateTime(DateTime.now().subtract(Duration(days: 1)).year, DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day)).toUtc().toIso8601String()})";
      filters = Uri(queryParameters: {'filters': filters, 'lite': '1'}).query;
      final rawData = await _getAuthRequest('orders/order/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      print(e.toString());
      return List<Order>.empty();
    }
  }

  Future<List<Order>> getInProgOrders() async {
    try {
      String filters =
          "(created_at__gte=${(DateTime(DateTime.now().subtract(Duration(days: 1)).year, DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day)).toUtc().toIso8601String()}) & (status__in=2,3)";
      filters = Uri(queryParameters: {'filters': filters, 'lite': '1'}).query;
      final rawData = await _getAuthRequest('orders/order/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      return List<Order>.empty();
    }
  }

  Future<List<Order>> getReadyOrders() async {
    try {
      String filters =
          "(created_at__gte=${(DateTime(DateTime.now().subtract(Duration(days: 1)).year, DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day)).toUtc().toIso8601String()}) & (status=4)";
      filters = Uri(queryParameters: {'filters': filters, 'lite': '1'}).query;
      final rawData = await _getAuthRequest('orders/order/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      return List<Order>.empty();
    }
  }

  Future<List<Order>> getFinishedOrders() async {
    try {
      String filters =
          "(created_at__gte=${(DateTime(DateTime.now().subtract(Duration(days: 1)).year, DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day)).toUtc().toIso8601String()}) & (status=5)";
      filters = Uri(queryParameters: {'filters': filters, 'lite': '1'}).query;
      final rawData = await _getAuthRequest('orders/order/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      return List<Order>.empty();
    }
  }

  Future<List<Order>> getSearchOrders(String query) async {
    try {
      String filters =
          "(first_name=$query) | (last_name=$query) | (slug=$query) | (phone=$query)";
      filters = Uri(queryParameters: {'filters': filters, 'lite': '1'}).query;
      final rawData = await _getAuthRequest('orders/order/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<Order>.from(jsonList.map((model) => Order.fromJson(model)));
    } catch (e) {
      return List<Order>.empty();
    }
  }

  Future<Order?> getOrder(int id) async {
    try {
      final rawData = await _getAuthRequest('orders/order/$id');
      return Order.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }

  Future<Meal?> getMeal(int id) async {
    try {
      final rawData = await _getAuthRequest('menu/meal/$id/');
      return Meal.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }

  Future<void> changeEta(int id, Duration eta) async {
    try {
      await _postAuthRequest(
          'orders/order/$id/add_eta/', "{\"eta\":\"${eta.toString()}\"}");
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await _deleteAuthRequest('orders/order/$id/');
    } catch (e) {
      return null;
    }
  }

  Future<Addon?> getAddon(int id) async {
    try {
      final rawData = await _getAuthRequest('menu/addon/$id/');
      return Addon.fromRawJson(rawData);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<MealSize?> getMealSize(int id) async {
    try {
      final rawData = await _getAuthRequest('menu/meal_size/$id/');
      return MealSize.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }

  Future<MealCategory?> getCategory(int id) async {
    try {
      final rawData = await _getAuthRequest('menu/meal_category/$id/');
      return MealCategory.fromRawJson(rawData);
    } catch (e) {
      return null;
    }
  }

  Future<void> acceptOrder(int id, Duration? eta) async {
    await _postAuthRequest(
        'orders/order/$id/accept/',
        Acceptation(
                accepted: true, eta: eta != null ? eta.toString() : "00:00:00")
            .toRawJson());
  }

  Future<void> rejectOrder(int id) async {
    await _postAuthRequest(
        'orders/order/$id/accept/', Acceptation(accepted: false).toRawJson());
  }

  Future<void> readyOrder(int id) async {
    await _postAuthRequest('orders/order/$id/change_status/', "{\"status\":4}");
  }

  Future<void> finishOrder(int id) async {
    await _postAuthRequest('orders/order/$id/change_status/', "{\"status\":5}");
  }

  Future<void> doneOrder(int id) async {
    await _postAuthRequest('orders/order/$id/change_status/', "{\"status\":7}");
  }

  Future<Zone> getZone(int id) async {
    final rawData = await _getAuthRequest('settings/zone/$id/');
    return Zone.fromRawJson(rawData);
  }

  Future<Section> getSection(int id) async {
    final rawData = await _getAuthRequest('settings/section/$id/');
    return Section.fromRawJson(rawData);
  }

  Future<void> unNew(int id) async {
    await _getAuthRequest('orders/order/$id/un_new/');
  }

  Future<bool> verifyToken() async {
    try {
      await _postRequest("token/verify/",
          "{\"token\":\"${await locator<SecureStorageService>().accessToken}\"}");
    } catch (c) {
      return false;
    }
    return true;
  }

  Future<String?> getTableName(int id) async {
    try {
      dynamic tmp = await _getAuthRequest("settings/dine_table/$id/");
      tmp = json.decode(tmp);
      return tmp["name"];
    } catch (c) {
      return null;
    }
  }

  Future<bool> patchSuperClosed(bool da) async {
    try {
      await _patchAuthRequest(
          "settings/restaurant/1/super_close/", "{\"is_super_closed\":$da}");
    } catch (c) {
      return false;
    }
    return true;
  }

  Future<List<TableReservation>> getTableReservations() async {
    try {
      String filters =
          "(created_at__gte=${(DateTime(DateTime.now().subtract(Duration(days: 1)).year, DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day)).toUtc().toIso8601String()}) & (status__in=1,2)";
      filters = Uri(queryParameters: {'filters': filters}).query;
      final rawData =
          await _getAuthRequest('orders/table_reservation/?$filters');
      final Iterable jsonList = json.decode(rawData);
      return List<TableReservation>.from(
          jsonList.map((model) => TableReservation.fromMap(model)));
    } catch (c) {
      return List<TableReservation>.empty();
    }
  }

  Future<void> deleteTable(int id) async {
    try {
      await _deleteAuthRequest('orders/table_reservation/$id/');
    } catch (e) {
      return null;
    }
  }

  Future<void> acceptTable(int id) async {
    try {
      await _postAuthRequest(
          'orders/table_reservation/$id/change_status/', "{\"status\": 2}");
    } catch (e) {
      return null;
    }
  }

  Future<void> finishTable(int id) async {
    try {
      await _postAuthRequest(
          'orders/table_reservation/$id/change_status/', "{\"status\": 4}");
    } catch (e) {
      return null;
    }
  }

  Future<void> rejectTable(int id) async {
    try {
      await _postAuthRequest(
          'orders/table_reservation/$id/change_status/', "{\"status\": 3}");
    } catch (e) {
      return null;
    }
  }
}
