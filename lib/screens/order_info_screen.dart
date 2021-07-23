import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import '../models/order.dart';

class OrderInfo extends StatelessWidget {
  final Order order;
  const OrderInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Kcolor,
            title: Text(
          "#${order.slug}",
        )),
        body: Container(
          child: Card(
            margin: EdgeInsets.all(10),                                     
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(
                      width: 16,
                    ),
                    Text("${order.firstName} ${order.lastName}"),
                  ],
                ),
                Divider(height: 16,),

                Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(
                      width: 16,
                    ),
                    Text(order.phone)
                  ],
                ),
                Divider(height: 16,),
                Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(
                      width: 16,
                    ),
                    Text(order.email)
                  ],
                ),
                Divider(height: 16,),
                Row(
                  children: [
                    order.type == 1
                        ? Icon(Icons.delivery_dining)
                        : Icon(Icons.hail),
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
                    : Row(
                        children: [
                          Icon(
                            Icons.delivery_dining
                          )
                          ,SizedBox(
                            width: 16,
                          ),
                          Text(order.delivery!.address)
                        ],
                      )
              ],
            ),
          ),
        ));
  }
}
