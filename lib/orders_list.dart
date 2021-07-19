import 'package:flutter/material.dart';
import 'models/order.dart';

class OrdersList extends StatelessWidget {
  final List<Order> orders;
  OrdersList({required this.orders});
  Card _tile(Order order) => Card(
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
        ),
      );

  ListView _ordersListView() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        return _tile(orders[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) => _ordersListView();
}
