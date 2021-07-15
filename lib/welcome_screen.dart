import 'secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jallaliefern_taking_orders_app/api_url_form.dart';

class WelcomeScreen extends StatefulWidget {

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future? _apiUrl;
  @override
  void initState() {
    super.initState();
    _apiUrl = SecureStorage.read("api_url");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _apiUrl,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Text('this is login screen');
        }
        else {
          return APIURLForm();
        }
      },
    );
  }
}