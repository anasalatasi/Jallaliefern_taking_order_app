import 'package:http/http.dart' as http;
import 'dart:async';
import '../../secure_storage.dart';
class ApiFormRepository {
  Future<bool> _testUrl(String apiUrl) async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl + '/api/settings/is_restaurant_open/'))
          .timeout(Duration(seconds: 3));
      if (response.statusCode != 200) return Future.value(false);
    } on TimeoutException {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> save({required String apiUrl}) async {
    final reachUrl = await _testUrl(apiUrl);
    if (!reachUrl) throw Exception('api is not reachable');
    SecureStorage.write("api_url",apiUrl + '/api/');
  }
}
