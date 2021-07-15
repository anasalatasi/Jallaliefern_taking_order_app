import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/page1.dart';
import 'package:jallaliefern_taking_orders_app/scaffold.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'Constants.dart';
import 'scaffold.dart';
import 'welcome_screen.dart';

void main() {
  runApp(Phoenix(
      child: MaterialApp(
    home: WelcomeScreen(),
  )));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: orderScaffold());
  }
}
