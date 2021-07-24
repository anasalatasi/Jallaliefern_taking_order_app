import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/models/item.dart';
import 'package:jallaliefern_taking_orders_app/models/meal.dart';
import 'package:jallaliefern_taking_orders_app/models/meal_size.dart';
import 'package:jallaliefern_taking_orders_app/models/section.dart';
import 'package:jallaliefern_taking_orders_app/models/zone.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:duration_picker/duration_picker.dart';
import '../models/order.dart';

class OrderInfo extends StatelessWidget {
  final Order order;
  OrderInfo({required this.order});

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

  Future<void> _showRejectDialog(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Reject Order #${order.id}"),
            content: Text("Are you sure you want to reject this order?"),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          child: Text('CANCEL'),
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
                          child: Text('CONFIRM'),
                          onPressed: () async {
                            try {
                              await locator<ApiService>().rejectOrder(order.id);
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

  Future<void> _showAcceptDialog(BuildContext context) async => showDialog(
      context: context,
      builder: (context) {
        Duration _duration = Duration();
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Accept Order #${order.id}'),
            content: DurationPicker(
                snapToMins: 5.0,
                duration: _duration,
                onChange: (val) {
                  setState(() => _duration = val);
                }),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          child: Text('CANCEL'),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                          child: Text('CONFIRM'),
                          onPressed: () {
                            setState(() async {
                              try {
                                await locator<ApiService>()
                                    .acceptOrder(order.id, _duration);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } catch (e) {
                                await _showErrorDialog(context, e.toString());
                              }
                            });
                          }),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Kcolor,
          title: Text(
            "#${order.id}",
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
                      _deliveryWidget(),
                      _itemsListView(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
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
                        child: Text('Reject'),
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
                      onPressed: () async => await _showAcceptDialog(context),
                      label: Center(
                        child: Text('Accept'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryWidget() {
    return Column(
      children: [
        Row(
          children: [
            order.type == 1 ? Icon(Icons.delivery_dining) : Icon(Icons.hail),
            SizedBox(
              width: 16,
            ),
            Text(order.getType())
          ],
        ),
        order.delivery == null
            ? SizedBox(
                width: 0,
              )
            : Column(
                children: [
                  FutureBuilder(
                      future: order.delivery!.getZone(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Zone?> snapshot) {
                        if (!snapshot.hasData)
                          return Row(
                            children: [
                              Text("Zone: Loading"),
                            ],
                          );
                        return Row(
                          children: [Text("Zone: ${snapshot.data!.name}")],
                        );
                      }),
                  order.delivery!.sectionId == null
                      ? Row(
                          children: [
                            Text("Section: ${order.delivery!.sectionName}")
                          ],
                        )
                      : FutureBuilder(
                          future: order.delivery!.getSection(),
                          builder: (BuildContext context,
                              AsyncSnapshot<Section?> snapshot) {
                            if (!snapshot.hasData)
                              return Row(children: [
                                Text('Section: Loading'),
                              ]);
                            return Row(
                              children: [
                                Text("Section: ${snapshot.data!.name}")
                              ],
                            );
                          }),
                  Row(
                    children: [
                      Text("Address: ${order.delivery!.address}"),
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  Widget _itemTile(Item item) {
    return Card(
        child: Column(
      children: [
        Row(
          children: [
            Text("Meal: "),
            FutureBuilder(
              future: item.getMeal(),
              builder: (BuildContext context, AsyncSnapshot<Meal?> snapshot) {
                if (!snapshot.hasData) return Text('Loading');
                return Text("${snapshot.data!.name}");
              },
            ),
          ],
        ),
        item.size == null
            ? Container()
            : Row(
                children: [
                  Text('Size: '),
                  FutureBuilder(
                    future: item.getMealSize(),
                    builder: (BuildContext context,
                        AsyncSnapshot<MealSize?> snapshot) {
                      if (!snapshot.hasData) return Text('Loading');
                      return Text("${snapshot.data!.name}");
                    },
                  )
                ],
              ),
        Row(
          children: [Text('Quantity: x${item.quantity}')],
        ),
        Row(
          children: [
            Text('Notes: ${Utf8Decoder().convert(item.notes!.codeUnits)}')
          ],
        ),
        Row(
          children: [Text('Price: ${item.totalPrice}')],
        ),
      ],
    ));
  }

  Widget _itemsListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: order.items.length,
        itemBuilder: (BuildContext context, int index) =>
            _itemTile(order.items[index]),
      ),
    );
  }

  Row emailwidget() {
    return Row(
      children: [
        Icon(Icons.email),
        SizedBox(
          width: 16,
        ),
        Text(order.email)
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
        Text(order.phone)
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
        Text("${order.firstName} ${order.lastName}"),
      ],
    );
  }
}
