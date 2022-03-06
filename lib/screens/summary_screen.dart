import 'dart:math';
import 'dart:typed_data';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart' as PosBluetooth;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';

import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_sunmi_printer/flutter_sunmi_printer.dart';

import '../models/summary.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime? startDate, endDate;
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    startDate = args.value.startDate;
    endDate = args.value.endDate;
  }

  PosBluetooth.PrinterBluetoothManager printerManager =
      locator<PrinterService>().printerManager;
  NetworkPrinter? printerNetworkManager;
  String myEncoding(String str) {
    str = str.replaceAll("Ä", "A");
    str = str.replaceAll("ä", "a");
    str = str.replaceAll("Ö", "O");
    str = str.replaceAll("ö", "o");
    str = str.replaceAll("ü", "u");
    str = str.replaceAll("Ü", "U");
    str = str.replaceAll("ẞ", "SS");
    str = str.replaceAll("ß", "ss");
    return String.fromCharCodes(Uint8List.fromList(str.codeUnits));
  }

  Future<void> ticket(Summary summary, NetworkPrinter printer) async {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    printer.text(timestamp,
        styles: PosStyles(align: PosAlign.center, bold: true));

    printer.text(
      myEncoding(locator<Restaurant>().name!),
      styles: PosStyles(
        bold: true,
      ),
    );
    final formatter2 = DateFormat('MM/dd/yyyy');
    String fromtimestamp = formatter2.format(startDate!);
    String totimestamp = formatter2.format(endDate!);
    printer.text("$fromtimestamp -> $totimestamp",
        styles: PosStyles(bold: true), linesAfter: 1);

    printer.hr(ch: "=");

    for (int i = 0; i < summary.orders!.length; i++) {
      printer.row([
        PosColumn(text: 'id: ', width: 4, styles: PosStyles(bold: true)),
        PosColumn(
            text: "#${summary.orders![i].id}",
            width: 8,
            styles: PosStyles(bold: true))
      ]);
      printer.row([
        PosColumn(text: 'slug: ', width: 4, styles: PosStyles(bold: true)),
        PosColumn(
            text: "${summary.orders![i].slug}",
            width: 8,
            styles: PosStyles(bold: true))
      ]);

      printer.row([
        PosColumn(
            text: 'Total price: ', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: "${summary.orders![i].totalPrice}",
            width: 6,
            styles: PosStyles(bold: true))
      ]);

      printer.row([
        PosColumn(
            text: 'Order Ended at: ', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: formatter.format(DateTime.parse(summary.orders![i].endedAt!)),
            width: 6,
            styles: PosStyles(bold: true))
      ]);

      printer.row([
        PosColumn(
            text: 'Payment type: ', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: summary.orders![i].paymentType == 1 ? "Cash" : "Paypal",
            width: 6,
            styles: PosStyles(bold: true))
      ]);

      if (i != summary.orders!.length - 1) printer.hr(ch: "-");
    }

    printer.hr(ch: "=");
    printer.row([
      PosColumn(text: 'Total Cash: ', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: "${summary.sumCash}", width: 6, styles: PosStyles(bold: true))
    ]);
    printer.row([
      PosColumn(
          text: 'Total Paypal: ', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: "${summary.sumPaypal ?? 0.0}",
          width: 6,
          styles: PosStyles(bold: true))
    ]);
    printer.row([
      PosColumn(text: 'Total sum: ', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: "${summary.sumTotal}", width: 6, styles: PosStyles(bold: true))
    ]);

    printer.emptyLines(2);
  }

  void _print() async {
    if (startDate == null || endDate == null) {
      showToast("please select a valid range");
      return;
    }
    var summary =
        await locator<ApiService>().getSummaryReceipt(startDate!, endDate!);

    if (summary != null) {
      CapabilityProfile profile = await CapabilityProfile.load();
      NetworkPrinter printer = NetworkPrinter(
          (await locator<SecureStorageService>().paper == "58")
              ? PaperSize.mm58
              : PaperSize.mm80,
          profile);
      PosPrintResult res = await printer
          .connect(await locator<SecureStorageService>().printerIp, port: 9100);
      if (res != PosPrintResult.success) {
        showToast("Es kann keine Verbindung zum Drucker hergestellt werden");
      } else {
        await ticket(summary, printer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Kcolor,
          title: Text("Print Summary Receipt"),
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
              ElevatedButton(
                  onPressed: _print,
                  child: Text(
                    "Print",
                    style: TextStyle(fontSize: 20),
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
