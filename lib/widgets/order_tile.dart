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
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  order.type == 1 ? Icons.delivery_dining : Icons.hail,
                  size: 55.0,
                ),
              ],
            ),
            title: Text(
              order.firstName,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(order.getType()),
            trailing: order.status != 3
                ? SizedBox()
                : CountdownTimer(
                    endTime: order.serveDateTime.millisecondsSinceEpoch,
                    widgetBuilder: (_, time) {
                      if (time == null) {
                        return Text('00:00:00');
                      }
                      return Text(
                          '${time.hours ?? 0}:${time.min ?? 0}:${time.sec ?? 0}');
                    },
                  ),
          ),
        ),
      );
}
