import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/screens/print_screen.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:badges/badges.dart';

import '../models/order.dart';
import 'package:flutter/material.dart';
import '../screens/order_info_screen.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    required this.order,
    required this.parentRefresh,
  });

  final Order order;
  final Future<void> Function() parentRefresh;
  @override
  Widget build(BuildContext context) => Card(
        elevation: 3,
        child: InkWell(
            onTap: () async {
              if (order.isNew) {
                locator<ApiService>().unNew(order.id);
              }
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderInfo(
                      order: order,
                    ),
                  ));
              parentRefresh();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                              "${DateFormat('kk:mm').format(DateTime.parse(order.createdAt).toLocal())}",
                              style: orderTileTimeStyle),
                          SizedBox(width: 5),
                          order.isNew
                              ? Badge(
                                  toAnimate: false,
                                  shape: BadgeShape.square,
                                  badgeColor: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                  badgeContent: Text('neue Bestellung',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                )
                              : SizedBox(width: 16),
                        ],
                      ),
                      Row(
                        children: [
                          order.type == 2
                              ? Icon(
                                  Icons.hail,
                                  size: 30,
                                )
                              : Icon(Icons.delivery_dining, size: 30),
                          Text("${order.getType()}", style: orderTileIconStyle),
                        ],
                      )
                    ],
                  ),
                  (order.status == 3)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CountdownTimer(
                              endTime:
                                  order.serveDateTime.millisecondsSinceEpoch,
                              widgetBuilder: (_, time) {
                                if (time == null) {
                                  return Text('AUSZEIT',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold));
                                }
                                return Text(
                                    '${time.hours ?? 0}:${time.min ?? 0}:${time.sec ?? 0}',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold));
                              },
                            )
                          ],
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("#${order.id}"),
                      Text(
                          "${order.totalPrice} ${locator<Restaurant>().currency ?? ""}")
                    ],
                  ),
                  Row(
                    children: [
                      Text("${order.firstName} ${order.lastName}"),
                    ],
                  ),
                  order.delivery == null
                      ? SizedBox()
                      : Column(
                          children: [
                            Row(
                              children: [
                                Text("${order.delivery!.address}"),
                              ],
                            ),
                            Row(
                              children: [
                                Text("${order.delivery!.section ?? ""}"),
                                order.delivery!.zone == null
                                    ? SizedBox()
                                    : Text(" - ${order.delivery!.zone!.name}"),
                              ],
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${order.phone}"),
                      Text(
                          "${DateFormat('yyyy-MM-dd').format(DateTime.parse(order.createdAt).toLocal())}"),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PrintScreen(order: order)));
                            },
                            icon: Icon(Icons.print),
                            label: Text("drucken"),
                          ),
                        ),
                      ),
                      order.status == 1
                          ? StateWidget(
                              state: 'Ausstehend', color: Colors.purple)
                          : order.status == 2
                              ? StateWidget(
                                  state: 'Abgelehnt', color: Colors.red)
                              : order.status == 3
                                  ? StateWidget(
                                      state: 'Akzeptiert', color: Colors.green)
                                  : order.status == 4
                                      ? StateWidget(
                                          state: 'Lieferung ausstehend',
                                          color: Colors.deepPurple)
                                      : order.status == 5
                                          ? StateWidget(
                                              state: 'Liefern',
                                              color: Colors.cyan)
                                          : order.status == 6
                                              ? StateWidget(
                                                  state: "Geliefert",
                                                  color: Colors.blueGrey)
                                              : StateWidget(
                                                  state: 'Fertig',
                                                  color: Kcolor)
                    ],
                  ),
                ],
              ),
            )),
      );
}

class StateWidget extends StatelessWidget {
  StateWidget({required this.state, required this.color});
  final String state;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            onPressed: null,
            child: Center(
              child: Text(
                state,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13),
              ),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => color))),
      ),
    );
  }
}
