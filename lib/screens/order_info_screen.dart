import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import '../models/order.dart';
import '../models/meal.dart';

class OrderInfo extends StatelessWidget {
  final Order order;
  OrderInfo({required this.order});

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
                        Icon(Icons.delivery_dining),
                        SizedBox(
                          width: 16,
                        ),
                        Text(order.delivery!.address)
                      ],
                    ),
               Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary:Colors.red
            ),
            icon: Icon(Icons.add_task),
            onPressed: () {},
            label: Center(child: Text('Reject'),),
          ),
          SizedBox(width: 16,),
          ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              primary:Colors.green
            ),
            
            icon: Icon(Icons.cancel_outlined),
          //  style: ButtonStyle(backgroundColor: MaterialStateProperty<Color>),
            onPressed: () {},
            label: Center(child: Text('Accept'),),
          ),
        ],
      ), 
            ],
          ),
        ),
      ),
    );
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
}
