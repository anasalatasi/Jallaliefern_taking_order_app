import 'package:http/http.dart' as http;
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'dart:async';
import '../../services/secure_storage_service.dart';
class ApiFormRepository {
  Future<bool> _testUrl(String apiUrl) async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl + '/api/settings/is_restaurant_open/'))
          .timeout(TIMEOUT);
      if (response.statusCode != 200) return Future.value(false);
    } on Exception {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> save({required String apiUrl}) async {
    final reachUrl = await _testUrl(apiUrl);
    if (!reachUrl) throw Exception('api is not reachable');
    await locator<SecureStorageService>().write("api_url",apiUrl + '/api/');
  }
}
