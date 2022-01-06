import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DriversScreen extends StatefulWidget {
  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  DateTime? startDate, endDate;
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    startDate = args.value.startDate;
    endDate = args.value.endDate;
  }

  void _onPrintAll() async {
    if (startDate == null || endDate == null) {
      showToast("please select a valid range");
      return;
    }
    dynamic receipts =
        await locator<ApiService>().getDriverReceiptAll(startDate!, endDate!);
  }

  void _onSelectDriver(int id) async {
    if (startDate == null || endDate == null) {
      showToast("please select a valid range");
      return;
    }
    dynamic receipt =
        await locator<ApiService>().getDriverReceipt(id, startDate!, endDate!);
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Kcolor,
          title: Text("Print Drivers Receipt"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(children: [
              Text("Choose date range", style: TextStyle(fontSize: 20)),
              SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged: _onSelectionChanged,
                  maxDate: DateTime.now()),
              Text("Choose a Driver", style: TextStyle(fontSize: 20)),
              FutureBuilder(
                  future: locator<ApiService>().getDrivers(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) => ListTile(
                              onTap: () =>
                                  _onSelectDriver(snapshot.data[index].id),
                              title: Text(
                                "${snapshot.data[index].firstName} ${snapshot.data[index].lastName}",
                                style: TextStyle(fontSize: 20),
                              ))),
                    );
                  }),
              ElevatedButton(
                  onPressed: _onPrintAll,
                  child: Text(
                    "Print All",
                    style: TextStyle(fontSize: 20),
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
