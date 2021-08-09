import 'dart:ffi';

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
            child: Column(
              children: [
                Row(
                  children: [
                    Text("${order.createdAt}"),
                    SizedBox(
                      width: 16,
                    ),
                    Text("${order.getType()}")
                  ],
                ),
                Row(
                  children: [Text("${order.id}"), Text("${order.totalPrice}")],
                ),
                Row(
                  children: [
                    Text("${order.firstName}"),
                    Text("${order.lastName}"),
                  ],
                ),
                    order.delivery==null ? SizedBox() : Column(
                      children: [
                      Text("${order.delivery!.address}"),

                      Row(
                        children: [
                          Text("${order.delivery!.zoneId.toString()}"),
                          Text("${order.delivery!.zone!.name}"),
                        ],
                      ),
                      ],
                ),
                Text("${order.phone}")
              ],
            )),
      );
}
