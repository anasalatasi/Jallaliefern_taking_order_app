import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/models/order.dart';
import 'package:jallaliefern_taking_orders_app/widgets/order_tile.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Constants.dart';

class AcceptedPage extends StatefulWidget {
  @override
  _AcceptedPageState createState() => _AcceptedPageState();
}

class _AcceptedPageState extends State<AcceptedPage>
    with WidgetsBindingObserver {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Order> orders = List<Order>.empty();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((message) {
      _onRefresh();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    _refreshController.requestRefresh();
    try {
      final tmp = await locator<ApiService>().getAcceptedOrders();
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
      header: WaterDropMaterialHeader(
        backgroundColor: Kcolor,
      ),
      enablePullDown: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          return OrderTile(order: orders[index], parentRefresh: _onRefresh);
        },
      ));
}
