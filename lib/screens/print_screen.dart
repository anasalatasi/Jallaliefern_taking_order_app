import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/order.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrintScreen extends StatefulWidget {
  final Order order;

  PrintScreen({required this.order});

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  bool? bluetoothEnabled;

  Future<void> _onRefresh() async {
    try {
      bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Kcolor,
        title: Text("Print Order #${widget.order.id}"),
      ),
      body: SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _child(context)));

  Widget _child(context) {
    if (bluetoothEnabled == null) return Text('Checking bluetooth');
    if (bluetoothEnabled!) return Text('bluetooth is enabled');
    return Text('bluetooth is disabled');
  }
}
