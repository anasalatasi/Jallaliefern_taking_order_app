import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/models/table_reservation.dart';
import 'package:jallaliefern_taking_orders_app/screens/print_screen.dart';
import 'package:jallaliefern_taking_orders_app/screens/table_info_screen.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:badges/badges.dart';

import '../models/order.dart';
import 'package:flutter/material.dart';
import '../screens/order_info_screen.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class TableReservationTile extends StatelessWidget {
  const TableReservationTile({
    required this.tableReservation,
    required this.parentRefresh,
  });

  final TableReservation tableReservation;
  final Future<void> Function() parentRefresh;
  @override
  Widget build(BuildContext context) => Card(
        elevation: 3,
        child: InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableInfoScreen(
                      table: tableReservation,
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
                              "${DateFormat('kk:mm').format(DateTime.parse(tableReservation.createdAt).toLocal())}",
                              style: orderTileTimeStyle),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.restaurant, size: 30),
                          Text("Table", style: orderTileIconStyle),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("#${tableReservation.id}")],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${tableReservation.firstName} ${tableReservation.lastName}"),
                      Text(
                          "${DateFormat('yyyy-MM-dd').format(DateTime.parse(tableReservation.createdAt).toLocal())}"),
                    ],
                  ),
                  Row(
                    children: [
                      tableReservation.status == 1
                          ? StateWidget(
                              state: 'Ausstehend', color: Colors.purple)
                          : tableReservation.status == 2
                              ? StateWidget(
                                  state: 'Akzeptiert', color: Colors.green)
                              : tableReservation.status == 3
                                  ? StateWidget(
                                      state: 'Abgelehnt', color: Colors.red)
                                  : StateWidget(
                                      state: 'Lieferung ausstehend',
                                      color: Colors.deepPurple)
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
