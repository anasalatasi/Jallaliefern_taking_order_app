import 'dart:io';
import 'secure_storage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'welcome_screen.dart';

class _APIURLFormState extends State<APIURLForm> {
  final _formkey = GlobalKey<FormState>();
  Future<String?> _validateURL(String? value) async {
    if (value == null) return 'url is required';
    if (!isURL(value)) return 'not a valid url';
    final response =
        await http.get(Uri.parse(value + '/api/settings/is_restaurant_open/'));
    if (response.statusCode != 200) return 'url is not reachable';
  }

  String? _urlValidator;
  String? _apiurl;
  Future _saveurl(String? url) async {
    if (url == null) url = '';
    await SecureStorage.write("api_url", url + '/api/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                      builder: (context) => Form(
                            key: _formkey,
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Website URL:'),
                                validator: (value) => _urlValidator,
                                onSaved: (val) => _apiurl = val),
                          )),
                  Container(
                      child: ElevatedButton(
                          onPressed: () async {
                            final form = _formkey.currentState;
                            if (form!.validate()) {
                              form.save();
                              String? response = await _validateURL(_apiurl);
                              setState(() {
                                _urlValidator = response;
                              });
                              if (form.validate()) {
                                await _saveurl(_apiurl);
                                sleep(Duration(seconds: 1));
                                Phoenix.rebirth(context);
                              }
                            }
                          },
                          child: Text('Save'))),
                ],
              )),
        ),
      ),
    );
  }
}

class APIURLForm extends StatefulWidget {
  APIURLForm({Key? key}) : super(key: key);

  @override
  _APIURLFormState createState() => _APIURLFormState();
}
