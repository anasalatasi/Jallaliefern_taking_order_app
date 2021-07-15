import 'dart:io';
import 'secure_storage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'welcome_screen.dart';
class _APIURLFormState extends State<APIURLForm> {
  final _formkey = GlobalKey<FormState>();
  String? validateURL(String value) => isURL(value) ? null : 'not a valid url';

  Future _saveurl(String? url) async {
    if (url == null) url = '';
    await SecureStorage.write("api_url",url+'/api/');
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
                            validator: (value) => value!.isEmpty
                                ? 'URL is required'
                                : validateURL(value),
                                onSaved: (val) async {await _saveurl(val);}
                                ),
                  )),
                  Container(
                      child: ElevatedButton(
                          onPressed: () async {
                            final form = _formkey.currentState;
                            if (form!.validate()) {
                              form.save();
                              sleep(Duration(seconds: 1));
                              Phoenix.rebirth(context);
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
