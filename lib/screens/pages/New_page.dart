import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/models/order.dart';
import 'package:jallaliefern_taking_orders_app/widgets/order_tile.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewPage extends StatefulWidget {
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Order> orders = List<Order>.empty();
  void _onRefresh() async {
    try {
      final tmp = await locator<ApiService>().getNewOrders();
      setState(() {
        orders = tmp;
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) => SmartRefresher(
      enablePullDown: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          return OrderTile(order: orders[index]);
        },
      ));
}
