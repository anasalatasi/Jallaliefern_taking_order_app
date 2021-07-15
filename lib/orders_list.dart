import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'order.dart';

class orders_list extends StatefulWidget {
  orders_list({Key? key}) : super(key: key);

  @override
  _orders_listState createState() => _orders_listState();
}

class _orders_listState extends State<orders_list> {
  Card _tile(Order order) =>  Card(
    child: ListTile(
  
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(order.type==1 ?Icons.delivery_dining : Icons.hail,
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

  ListView _orders_list_view(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return _tile(data[index]);
      },
    );
  }

  Future<List<Order>> _fetch_orders() async {
    List json_response = jsonDecode("""[{
    "id": 37,
    "slug": "2uge5",
    "first_name": "dada",
    "last_name": "dodo",
    "email": "dada@dodo.com",
    "type": 1},
    {"id": 78,
    "slug": "2uye5",
    "first_name": "dada",
    "last_name": "dodo",
    "email": "dada@dodo.com",
    "type": 2}]""");
    return json_response.map((order) => new Order.fromJson(order)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetch_orders(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _orders_list_view(snapshot.data);
        } else if (snapshot.hasError) return Text("${snapshot.error}");
        return CircularProgressIndicator();
      },
    );
  }
}
