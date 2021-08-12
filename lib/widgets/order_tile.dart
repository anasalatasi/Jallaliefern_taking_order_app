import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

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
                      Text(
                          "${DateFormat('kk:mm').format(DateTime.parse(order.createdAt))}",
                          style: orderTileTimeStyle),
                      SizedBox(
                        width: 16,
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
                          "${DateFormat('yyyy-MM-dd').format(DateTime.parse(order.createdAt))}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.print),
                    label: Expanded(child: Center(child: Text("Print"))),
                    style: ElevatedButton.styleFrom(
                    primary: Kcolor ,
                    ),  
                  ),
                  order.status == 1
                          ? StateWidget(state: 'Pending', color: Colors.purple)
                          : order.status == 2
                              ? StateWidget(state: 'Rejected', color: Colors.red)
                              : order.status == 3
                                  ? StateWidget(state: 'Accepted', color: Colors.green)
                                  : order.status == 4
                                      ? StateWidget(state: 'Pending Delivery', color: Colors.purple)
                                      : order.status == 5
                                          ? StateWidget(state: 'Delivering', color: Colors.cyanAccent)
                                          : order.status == 6
                                              ? StateWidget(state: "Delivered", color: Colors.blueGrey)
                                              : StateWidget(state: 'Done', color: Kcolor)
                      
                    ],
                  ),
                  
                ],
              ),
            )),
      );
}

class StateWidget extends StatelessWidget {
  StateWidget({required this.state , required this.color});
  final String state ;
  final Color color ;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Text(state,
        style: TextStyle(fontWeight: FontWeight.bold),
        ),
        color: color,
      ),
    );
}
}
