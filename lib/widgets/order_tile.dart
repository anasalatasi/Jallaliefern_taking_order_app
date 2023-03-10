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
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("#${order.id}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          order.isNew
                              ? Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Badge(
                                    toAnimate: false,
                                    shape: BadgeShape.square,
                                    badgeColor: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                    badgeContent: Text('neue Bestellung',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 8)),
                                  ),
                                )
                              : SizedBox(width: 16),
                          (order.isPreorder)
                              ? Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Badge(
                                    toAnimate: false,
                                    shape: BadgeShape.square,
                                    badgeColor: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                    badgeContent: Text('preorder',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 8)),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                      Row(
                        children: [
                          order.type == 2
                              ? Icon(
                                  Icons.hail,
                                  size: 20,
                                )
                              : order.type == 3
                                  ? Icon(Icons.restaurant, size: 20)
                                  : Icon(Icons.delivery_dining, size: 20),
                          Text("${order.getType()}  ",
                              style: orderTileIconStyle),
                          IconButton(
                            iconSize: 20,
                            icon: Icon(Icons.print),
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PrintScreen(order: order)));
                            },
                          ),
                        ],
                      ),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold));
                                }
                                return Text(
                                    '${time.hours ?? 0}:${time.min ?? 0}:${time.sec ?? 0}',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold));
                              },
                            )
                          ],
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('count: ${order.count}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Column(
                        children: [
                          Text("${order.firstName} ${order.lastName}"),
                          (order.type == 1)
                              ? Text(
                                  "${order.delivery!.address} ${order.delivery!.buildingNo}")
                              : Container()
                        ],
                      ),
                      Text(
                          "${DateFormat('yyyy-MM-dd - kk:mm').format(DateTime.parse(order.createdAt).toLocal())}"),
                    ],
                  ),
                  (order.isPreorder)
                      ? Row(
                          children: [
                            Text(
                              "Preorder time: ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                                "${DateFormat('yyyy-MM-dd ??? kk:mm').format(order.serveDateTime)}",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ],
                        )
                      : Container(),
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
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
            onPressed: null,
            child: Center(
              child: Text(
                state,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12),
              ),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => color))),
      ),
    );
  }
}
