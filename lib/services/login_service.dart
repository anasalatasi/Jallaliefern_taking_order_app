import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/exceptions.dart';

import '../models/jwt_token.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jwt_decode/jwt_decode.dart';

class LoginService {
  JwtToken? _token;
  final Map<String, String> _headers = {
    HttpHeaders.contentTypeHeader: 'application/json'
  };
  _loginToJson({required username, required password}) =>
      jsonEncode({"username": username, "password": password});

  Future<void> getToken({required username, required password}) async {
    final response = await http
        .post(
            Uri.parse(await locator<SecureStorageService>().apiUrl + 'token/'),
            headers: _headers,
            body: _loginToJson(username: username, password: password))
        .timeout(TIMEOUT);
    // print(response);
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 200) {
      var tmp = JwtToken.fromRawJson(response.body).access;
      Map<String, dynamic> payload = Jwt.parseJwt(tmp);
      if (payload['role'] != 3 && payload['role'] != 4) {
        throw UnauthorizedException();
      }
      _token = JwtToken.fromRawJson(response.body);
      await locator<SecureStorageService>()
          .write("access_token", _token!.access);
      // print(await locator<SecureStorageService>().accessToken);
      await locator<ApiService>().registerDevice();
    } else
      throw Exception(response.body);
  }
}
