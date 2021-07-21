import '../models/order.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) => Card(
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
}