import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
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

class OrderInfo extends StatelessWidget {
  final Order order;
  OrderInfo({required this.order});
  Future<void> showMyNote(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text('The Note of ${order.id} order :'),
          content: SingleChildScrollView(child: Text('${order.notes}')),
          actions: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }

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

  Future<void> _showConfirmReadyDialog(BuildContext context) async =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Confirm Order #${order.id} is Ready"),
                content:
                    Text("Are you sure you want to mark this order as ready?"),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
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
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text('CONFIRM'),
                              onPressed: () async {
                                try {
                                  await locator<ApiService>()
                                      .readyOrder(order.id);
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
                title: Text("Delete Order #${order.id}"),
                content: Text("Are you sure you want to delete this order?"),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
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
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text('CONFIRM'),
                              onPressed: () async {
                                try {
                                  await locator<ApiService>()
                                      .deleteOrder(order.id);
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
                title: Text("Confirm Order #${order.id} is Finished"),
                content: Text(
                    "Are you sure you want to mark this order as finished?"),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
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
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text('CONFIRM'),
                              onPressed: () async {
                                try {
                                  await locator<ApiService>()
                                      .finishOrder(order.id);
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
            title: Row(children: [
              Text('Accept Order #${order.id}'),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrintScreen(order: order)));
                  },
                  icon: Icon(Icons.print))
            ]),
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
                                locator<ApiService>()
                                    .acceptOrder(order.id, _duration)
                                    .then((_) {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PrintScreen(order: order)))
                                      .then((_) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  });
                                });
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

  Future<void> _showAddEtaDialog(BuildContext context) async => showDialog(
      context: context,
      builder: (context) {
        Duration _duration = Duration();
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add ETA for Order #${order.id}'),
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
                                    .changeEta(order.id, _duration);
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#${order.id}",
              ),
              Text('${order.totalPrice}'),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrintScreen(order: order)));
                  },
                  icon: Icon(Icons.print)),
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
                      Divider(
                        height: 16,
                      ),
                      ElevatedButton(
                          onPressed: () async => await showMyNote(context),
                          child: noteswidget(),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) => Kcolor))),
                      Divider(
                        height: 16,
                      ),
                      SizedBox(height: 8),
                      _itemsListView(),
                    ],
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
    if (order.status == 1) return _newButtons(context);
    if (order.status == 3) return _inProgButtons(context);
    if (order.status == 4) return _readyButtons(context);
    return Container();
  }

  Widget _inProgButtons(BuildContext context) {
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
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                    icon: Icon(Icons.edit),
                    onPressed: () async => await _showAddEtaDialog(context),
                    label: Center(
                      child: Text('Add ETA'),
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
                    onPressed: () async =>
                        await _showConfirmReadyDialog(context),
                    label: Center(
                      child: Text('Done'),
                    ),
                  ),
                ),
              ),
            ]));
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
                      child: Text('Finish'),
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
                          children: [Text("Section: no section")],
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

  Widget _addons(Item item) {
    if (item.addons == null) return SizedBox();
    var list = [];
    for (var i = 0; i < item.addons!.length; i++) {
      list.add(Text(item.addons![i].addonObject.name));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.from(list),
    );
  }

  Widget _itemTile(Item item) {
    return Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Meal: ", style: labelTextStyle),
                  Expanded(
                    child: Text("${item.mealObject.name}"),
                  ),
                ],
              ),
              Divider(
                height: 4,
              ),
              item.size == null
                  ? Container()
                  : Row(
                      children: [
                        Text('Size: ', style: labelTextStyle),
                        Text('${item.sizeObject!.name}')
                      ],
                    ),
              item.size == null
                  ? Container()
                  : Divider(
                      height: 4,
                    ),
              Row(
                children: [
                  Text('Quantity: ', style: labelTextStyle),
                  Text('x${item.quantity}')
                ],
              ),
              Divider(
                height: 4,
              ),
              Row(
                children: [
                  Text('Notes: ', style: labelTextStyle),
                  Expanded(child: Text('${item.notes}'))
                ],
              ),
              Divider(
                height: 4,
              ),
              Row(
                children: [
                  Text('Price:', style: labelTextStyle),
                  Text('${item.totalPrice}')
                ],
              ),
              Divider(
                height: 4,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Addons: ', style: labelTextStyle),
                  _addons(item)
                ],
              )
            ],
          ),
        ));
  }

  Widget _itemsListView() {
    return FutureBuilder(
        future: order.items,
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
            snapshot.hasData
                ? Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Container(child: _itemTile(snapshot.data[index])),
                    ),
                  )
                : CircularProgressIndicator());
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

  Row noteswidget() {
    return Row(
      children: [
        Icon(Icons.event_note),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Text(
            "${order.notes}",
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
