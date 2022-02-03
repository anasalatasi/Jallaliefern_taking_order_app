import 'dart:math';
import 'dart:typed_data';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
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
  PrinterNetworkManager printerNetworkManager =
      locator<PrinterService>().printerNetworkManager;
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

  Future<Ticket> ticketmm80(Driver receipt) async {
    final Ticket ticket = Ticket(PaperSize.mm80);
    if (locator<PrinterService>().codetable != null)
      ticket.setGlobalCodeTable(locator<PrinterService>().codetable);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text(timestamp,
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    ticket.text(
      locator<Restaurant>().name!,
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true,
      ),
    );
    final formatter2 = DateFormat('MM/dd/yyyy');
    String fromtimestamp = formatter2.format(startDate!);
    String totimestamp = formatter2.format(endDate!);
    ticket.text("$fromtimestamp -> $totimestamp",
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1),
        linesAfter: 1);

    ticket.row([
      PosColumn(
          text: 'Driver name: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.firstName} ${receipt.lastName}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);

    ticket.row([
      PosColumn(
          text: 'Phone Number: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.phoneNumber ?? ''}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);

    ticket.text(
      "Orders:",
      styles: PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true,
      ),
    );

    for (int i = 0; i < receipt.orders!.length; i++) {
      ticket.row([
        PosColumn(
            text: 'id: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("#${receipt.orders![i].id}"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);
      ticket.row([
        PosColumn(
            text: 'slug: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("${receipt.orders![i].slug}"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      Uint8List tmp;
      if (await receipt.orders![i].delivery!.getSection() != null) {
        tmp = myEncoding(
            "${receipt.orders![i].delivery!.address} ${receipt.orders![i].delivery!.buildingNo}, ${(await receipt.orders![i].delivery!.getSection())!.name} ${(await receipt.orders![i].delivery!.getSection())!.zipCode}");
      } else {
        tmp = myEncoding(
            "${receipt.orders![i].delivery!.address} ${receipt.orders![i].delivery!.buildingNo}");
      }
      List<Uint8List> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      ticket.row([
        PosColumn(
            text: 'Adresse: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: chunks[0],
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);
      for (var i = 1; i < chunks.length; i++) {
        ticket.row([
          PosColumn(
              text: ' ',
              width: 4,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1)),
          PosColumn(
              textEncoded: chunks[i],
              width: 8,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1))
        ]);
      }

      ticket.row([
        PosColumn(
            text: 'Total price: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("${receipt.orders![i].totalPrice}"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      ticket.row([
        PosColumn(
            text: 'Delivery price: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("${receipt.orders![i].deliveryPrice}"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      ticket.row([
        PosColumn(
            text: 'Order Ended at: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding(
                formatter.format(DateTime.parse(receipt.orders![i].endedAt!))),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      ticket.row([
        PosColumn(
            text: 'Payment type: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding(
                receipt.orders![i].paymentType == 1 ? "Cash" : "Paypal"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      if (i != receipt.orders!.length - 1) ticket.hr(ch: "-");
    }

    ticket.hr(ch: "=");
    ticket.row([
      PosColumn(
          text: 'Total Cash: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.sumCash}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    ticket.row([
      PosColumn(
          text: 'Total Paypal: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.sumPaypal ?? 0}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    ticket.row([
      PosColumn(
          text: 'Total sum: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.sumTotal}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    return ticket;
  }

  Future<Ticket> ticketmm58(Driver receipt) async {
    final Ticket ticket = Ticket(PaperSize.mm58);
    if (locator<PrinterService>().codetable != null)
      ticket.setGlobalCodeTable(locator<PrinterService>().codetable);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text(timestamp,
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    ticket.text(
      locator<Restaurant>().name!,
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true,
      ),
    );
    final formatter2 = DateFormat('MM/dd/yyyy');
    String fromtimestamp = formatter2.format(startDate!);
    String totimestamp = formatter2.format(endDate!);
    ticket.text("$fromtimestamp -> $totimestamp",
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1),
        linesAfter: 1);

    ticket.row([
      PosColumn(
          text: 'Driver name: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.firstName} ${receipt.lastName}"),
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);

    ticket.row([
      PosColumn(
          text: 'Phone Number: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.phoneNumber ?? ''}"),
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);

    ticket.text(
      "Orders:",
      styles: PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true,
      ),
    );

    for (int i = 0; i < receipt.orders!.length; i++) {
      ticket.row([
        PosColumn(
            text: 'id: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("#${receipt.orders![i].id}"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);
      ticket.row([
        PosColumn(
            text: 'slug: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("${receipt.orders![i].slug}"),
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      Uint8List tmp;
      if (await receipt.orders![i].delivery!.getSection() != null) {
        tmp = myEncoding(
            "${receipt.orders![i].delivery!.address} ${receipt.orders![i].delivery!.buildingNo}, ${(await receipt.orders![i].delivery!.getSection())!.name} ${(await receipt.orders![i].delivery!.getSection())!.zipCode}");
      } else {
        tmp = myEncoding(
            "${receipt.orders![i].delivery!.address} ${receipt.orders![i].delivery!.buildingNo}");
      }
      List<Uint8List> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      ticket.row([
        PosColumn(
            text: 'Adresse: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: chunks[0],
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);
      for (var i = 1; i < chunks.length; i++) {
        ticket.row([
          PosColumn(
              text: ' ',
              width: 4,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1)),
          PosColumn(
              textEncoded: chunks[i],
              width: 8,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1))
        ]);
      }

      ticket.row([
        PosColumn(
            text: 'Total price: ',
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("${receipt.orders![i].totalPrice}"),
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      ticket.row([
        PosColumn(
            text: 'Delivery price: ',
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding("${receipt.orders![i].deliveryPrice}"),
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      ticket.row([
        PosColumn(
            text: 'Order Ended at: ',
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding(
                formatter.format(DateTime.parse(receipt.orders![i].endedAt!))),
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      ticket.row([
        PosColumn(
            text: 'Payment type: ',
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            textEncoded: myEncoding(
                receipt.orders![i].paymentType == 1 ? "Cash" : "Paypal"),
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);

      if (i != receipt.orders!.length - 1) ticket.hr(ch: "-");
    }

    ticket.hr(ch: "=");
    ticket.row([
      PosColumn(
          text: 'Total Cash: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.sumCash}"),
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    ticket.row([
      PosColumn(
          text: 'Total Paypal: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.sumPaypal ?? 0.0}"),
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    ticket.row([
      PosColumn(
          text: 'Total sum: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded: myEncoding("${receipt.sumTotal}"),
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    return ticket;
  }

  Future<Ticket> driverReceipt(Driver receipt) async {
    if (await locator<SecureStorageService>().paper == "58") {
      return await ticketmm58(receipt);
    }
    return await ticketmm80(receipt);
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
    await Future.delayed(Duration(seconds: 3));
    Ticket _ticket = await driverReceipt(receipt);
    try {
      if (!locator<PrinterService>().connected &&
          await locator<SecureStorageService>().printerIp != null &&
          await locator<SecureStorageService>().printerIp != "") {
        printerNetworkManager
            .selectPrinter(await locator<SecureStorageService>().printerIp);
        locator<PrinterService>().connected = true;
      }
      Ticket? tmp = _ticket;
      int n = 1;

      if (locator<PrinterService>().connected) {
        var res = await printerNetworkManager.printTicket(tmp);
        showToast(res.msg);
        for (int i = 1; i < n; i++) {
          await Future.delayed(Duration(seconds: 5));
          await printerNetworkManager.printTicket(tmp);
          showToast("$i");
        }
      } else {
        var res = await printerManager.printTicket(tmp);
        showToast(res.msg);
        for (int i = 1; i < n; i++) {
          await Future.delayed(Duration(seconds: 3));
          await printerManager.printTicket(tmp);
          showToast("$i");
        }
      }
    } catch (c) {
      showToast("Printer not connected");
    }
  }

  void _onSelectDriver(int id) async {
    if (startDate == null || endDate == null) {
      showToast("please select a valid range");
      return;
    }
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
