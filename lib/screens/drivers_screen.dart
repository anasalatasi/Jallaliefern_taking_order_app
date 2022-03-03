import 'dart:math';
import 'dart:typed_data';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_sunmi_printer/flutter_sunmi_printer.dart';
import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/models/driver.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
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

  PrinterBluetoothManager printerManager =
      locator<PrinterService>().printerManager;
  NetworkPrinter? printerNetworkManager;
  Uint8List myEncoding(String str) {
    str = str.replaceAll("Ä", "A");
    str = str.replaceAll("ä", "a");
    str = str.replaceAll("Ö", "O");
    str = str.replaceAll("ö", "o");
    str = str.replaceAll("ü", "u");
    str = str.replaceAll("Ü", "U");
    str = str.replaceAll("ẞ", "SS");
    str = str.replaceAll("ß", "ss");
    return Uint8List.fromList(str.codeUnits);
  }

  Future<void> ticketmm58(Driver receipt) async {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    SunmiPrinter.text(timestamp,
        styles: SunmiStyles(
          align: SunmiAlign.center,
        ));

    SunmiPrinter.text(
      locator<Restaurant>().name!,
      styles: SunmiStyles(
        align: SunmiAlign.center,
        bold: true,
      ),
    );
    final formatter2 = DateFormat('MM/dd/yyyy');
    String fromtimestamp = formatter2.format(startDate!);
    String totimestamp = formatter2.format(endDate!);
    SunmiPrinter.text("$fromtimestamp -> $totimestamp",
        styles: SunmiStyles(
          align: SunmiAlign.center,
        ),
        linesAfter: 1);

    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Driver name: ',
        width: 6,
      ),
      SunmiCol(
        text: "${receipt.firstName} ${receipt.lastName}",
        width: 6,
      )
    ]);

    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Phone Number: ',
        width: 6,
      ),
      SunmiCol(
        text: "${receipt.phoneNumber ?? ''}",
        width: 6,
      )
    ]);

    SunmiPrinter.text(
      "Orders:",
      styles: SunmiStyles(
        bold: true,
      ),
    );

    for (int i = 0; i < receipt.orders!.length; i++) {
      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'id: ',
          width: 4,
        ),
        SunmiCol(
          text: "#${receipt.orders![i].id}",
          width: 8,
        )
      ]);
      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'slug: ',
          width: 4,
        ),
        SunmiCol(
          text: "${receipt.orders![i].slug}",
          width: 8,
        )
      ]);

      List<int> tmp;
      if (await receipt.orders![i].delivery!.getSection() != null) {
        tmp =
            "${receipt.orders![i].delivery!.address} ${receipt.orders![i].delivery!.buildingNo}, ${(await receipt.orders![i].delivery!.getSection())!.name} ${(await receipt.orders![i].delivery!.getSection())!.zipCode}"
                .codeUnits;
      } else {
        tmp =
            "${receipt.orders![i].delivery!.address} ${receipt.orders![i].delivery!.buildingNo}"
                .codeUnits;
      }
      List<List<int>> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'Adresse: ',
          width: 4,
        ),
        SunmiCol(
          text: String.fromCharCodes(chunks[0]),
          width: 8,
        )
      ]);
      for (var i = 1; i < chunks.length; i++) {
        SunmiPrinter.row(cols: [
          SunmiCol(
            text: ' ',
            width: 4,
          ),
          SunmiCol(
            text: String.fromCharCodes(chunks[i]),
            width: 8,
          )
        ]);
      }

      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'Total price: ',
          width: 6,
        ),
        SunmiCol(
          text: "${receipt.orders![i].totalPrice}",
          width: 6,
        )
      ]);

      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'Delivery price: ',
          width: 6,
        ),
        SunmiCol(
          text: "${receipt.orders![i].deliveryPrice}",
          width: 6,
        )
      ]);

      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'Order Ended at: ',
          width: 6,
        ),
        SunmiCol(
          text: formatter.format(DateTime.parse(receipt.orders![i].endedAt!)),
          width: 6,
        )
      ]);

      SunmiPrinter.row(cols: [
        SunmiCol(
          text: 'Payment type: ',
          width: 6,
        ),
        SunmiCol(
          text: receipt.orders![i].paymentType == 1 ? "Cash" : "Paypal",
          width: 6,
        )
      ]);

      if (i != receipt.orders!.length - 1) SunmiPrinter.hr(ch: "-");
    }

    SunmiPrinter.hr(ch: "=");
    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Total Cash: ',
        width: 6,
      ),
      SunmiCol(
        text: "${receipt.sumCash}",
        width: 6,
      )
    ]);
    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Total Paypal: ',
        width: 6,
      ),
      SunmiCol(
        text: "${receipt.sumPaypal ?? 0.0}",
        width: 6,
      )
    ]);
    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Total sum: ',
        width: 6,
      ),
      SunmiCol(
        text: "${receipt.sumTotal}",
        width: 6,
      )
    ]);
    SunmiPrinter.emptyLines(2);
  }

  Future<void> driverReceipt(Driver receipt) async {
    await ticketmm58(receipt);
  }

  void _onPrintAll() async {
    if (startDate == null || endDate == null) {
      showToast("please select a valid range");
      return;
    }
    dynamic receipts =
        await locator<ApiService>().getDriverReceiptAll(startDate!, endDate!);
    receipts.forEach(_printReceipt);
  }

  void _printReceipt(Driver receipt) async {
    await driverReceipt(receipt);
  }

  void _onSelectDriver(int id) async {
    if (startDate == null || endDate == null) {
      showToast("please select a valid range");
      return;
    }
    final profile = await CapabilityProfile.load();
    final paper = (await locator<SecureStorageService>().paper == "58")
        ? PaperSize.mm58
        : PaperSize.mm80;
    printerNetworkManager = NetworkPrinter(paper, profile);
    dynamic receipt =
        await locator<ApiService>().getDriverReceipt(id, startDate!, endDate!);
    _printReceipt(receipt);
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
