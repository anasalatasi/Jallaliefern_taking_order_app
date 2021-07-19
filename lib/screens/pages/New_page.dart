import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/orders_list.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';


class NewPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: locator<ApiService>().getNewOrders(),
    builder: (BuildContext context,AsyncSnapshot snapshot) {
        if (snapshot.hasData) return OrdersList(orders: snapshot.data);
        return Container();
    });
}