import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:oktoast/oktoast.dart';

class DriversScreen extends StatefulWidget {
  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Kcolor,
        title: Text("Druckereinstellungen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: []),
      ),
    );
  }
}
