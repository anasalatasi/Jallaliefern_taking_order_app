import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/models/table_reservation.dart';
import 'package:jallaliefern_taking_orders_app/screens/print_screen.dart';
import 'package:jallaliefern_taking_orders_app/models/item.dart';
import 'package:jallaliefern_taking_orders_app/models/meal.dart';
import 'package:jallaliefern_taking_orders_app/models/meal_size.dart';
import 'package:jallaliefern_taking_orders_app/models/section.dart';
import 'package:jallaliefern_taking_orders_app/models/zone.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:duration_picker/duration_picker.dart';
import '../models/order.dart';

class TableInfoScreen extends StatelessWidget {
  final TableReservation table;
  TableInfoScreen({required this.table});

  Future<void> _showErrorDialog(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<void> _showConfirmAcceptDialog(BuildContext context) async =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("bestätigen Bestellung #${table.id} bereit"),
                content: Text(
                    "Möchten Sie diese Bestellung wirklich als fertig markieren?"),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              child: Text('Abbrechen'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text('bestätigen'),
                              onPressed: () async {
                                try {
                                  await locator<ApiService>()
                                      .acceptTable(table.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } catch (e) {
                                  await _showErrorDialog(context, e.toString());
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                ],
              ));

  Future<void> _showConfirmDeleteDialog(BuildContext context) async =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Bestellung löschen #${table.id}"),
                content: Text(
                    "bist du sicher, dass du diese Bestellung löschen möchtest?"),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              child: Text('Abbrechen'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text('bestätigen'),
                              onPressed: () async {
                                try {
                                  await locator<ApiService>()
                                      .deleteTable(table.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } catch (e) {
                                  await _showErrorDialog(context, e.toString());
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                ],
              ));

  Future<void> _showConfirmFinishDialog(BuildContext context) async =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("bestätigen Bestellung #${table.id} fertig"),
                content: Text(
                    "Möchten Sie diese Bestellung wirklich als abgeschlossen markieren?"),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              child: Text('Abbrechen'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text('bestätigen'),
                              onPressed: () async {
                                try {
                                  await locator<ApiService>()
                                      .finishTable(table.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } catch (e) {
                                  await _showErrorDialog(context, e.toString());
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                ],
              ));

  Future<void> _showRejectDialog(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Ablehnen Bestellung #${table.id}"),
            content: Text(
                "bist du sicher, dass du diese Bestellung ablehnen möchtest?"),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          child: Text('Abbrechen'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                          child: Text('bestätigen'),
                          onPressed: () async {
                            try {
                              await locator<ApiService>().rejectTable(table.id);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } catch (e) {
                              await _showErrorDialog(context, e.toString());
                            }
                          }),
                    ),
                  ),
                ],
              ),
            ],
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Kcolor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#${table.id}"),
              SizedBox(width: 5),
              IconButton(
                onPressed: () async => await _showConfirmDeleteDialog(context),
                icon: Icon(Icons.delete),
              ),
            ],
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              child: Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        infowidget(),
                        Divider(
                          height: 16,
                        ),
                        phonewidget(),
                        Divider(
                          height: 16,
                        ),
                        emailwidget(),
                        Divider(
                          height: 16,
                        ),
                        _datetimewidget(),
                        Divider(
                          height: 16,
                        ),
                        _otherinfoWidget(),
                        Divider(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buttons(context),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    if (table.status == 1) return _newButtons(context);
    if (table.status == 2) return _readyButtons(context);
    return Container();
  }

  Widget _readyButtons(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    icon: Icon(Icons.add_task),
                    onPressed: () async =>
                        await _showConfirmFinishDialog(context),
                    label: Center(
                      child: Text('beenden'),
                    ),
                  ),
                ),
              ),
            ]));
  }

  Widget _newButtons(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                icon: Icon(Icons.cancel_outlined),
                onPressed: () async => await _showRejectDialog(context),
                label: Center(
                  child: Text('Ablehnen'),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                icon: Icon(Icons.add_task),
                onPressed: () async {
                  await _showConfirmAcceptDialog(context);
                },
                label: Center(
                  child: Text('annehmen'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otherinfoWidget() {
    return Column(
      children: [
        Row(
          children: [
            Text("Persons Count: ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${table.personsCount}")
          ],
        ),
      ],
    );
  }

  Row emailwidget() {
    return Row(
      children: [
        Icon(Icons.email),
        SizedBox(
          width: 16,
        ),
        Text(table.email ?? "")
      ],
    );
  }

  Row phonewidget() {
    return Row(
      children: [
        Icon(Icons.phone),
        SizedBox(
          width: 16,
        ),
        Text(table.phone ?? "")
      ],
    );
  }

  Row infowidget() {
    return Row(
      children: [
        Icon(Icons.info),
        SizedBox(
          width: 16,
        ),
        Text("${table.firstName} ${table.lastName}"),
      ],
    );
  }

  Row _datetimewidget() {
    return Row(
      children: [
        Icon(Icons.access_time),
        SizedBox(
          width: 16,
        ),
        Text(
            "${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(table.datetime).toLocal())}"),
      ],
    );
  }
}
