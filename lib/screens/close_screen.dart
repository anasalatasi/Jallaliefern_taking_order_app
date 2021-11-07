import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

import '../Constants.dart';

class CloseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Kcolor,
          title: Row(children: [
            Text("Super Close Restaurant"),
          ])),
      body: Center(
        child: ElevatedButton(
          child: Text(locator<Restaurant>().isSuperClosed!
              ? "disable super close"
              : "super close"),
          style: ElevatedButton.styleFrom(
              primary: locator<Restaurant>().isSuperClosed!
                  ? Colors.green
                  : Colors.red),
          onPressed: () async {
            await locator<ApiService>()
                .patchSuperClosed(!locator<Restaurant>().isSuperClosed!);
            await locator<Restaurant>().init();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
