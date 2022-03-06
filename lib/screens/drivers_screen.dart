import 'dart:math';
import 'dart:typed_data';

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
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart' as PosBluetooth;

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

  Future<void> ticket(Driver receipt, NetworkPrinter printer) async {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    printer.text(myEncoding(timestamp),
        styles: PosStyles(
          align: PosAlign.center,
        ));

    printer.text(
      myEncoding(locator<Restaurant>().name!),
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    final formatter2 = DateFormat('MM/dd/yyyy');
    String fromtimestamp = formatter2.format(startDate!);
    String totimestamp = formatter2.format(endDate!);
    printer.text(myEncoding("$fromtimestamp -> $totimestamp"),
        styles: PosStyles(
          align: PosAlign.center,
        ),
        linesAfter: 1);

    printer.row([
      PosColumn(
        text: myEncoding('Driver name: '),
        width: 6,
      ),
      PosColumn(
        text: myEncoding("${receipt.firstName} ${receipt.lastName}"),
        width: 6,
      )
    ]);

    printer.row([
      PosColumn(
        text: myEncoding('Phone Number: '),
        width: 6,
      ),
      PosColumn(
        text: myEncoding("${receipt.phoneNumber ?? ''}"),
        width: 6,
      )
    ]);

    printer.text(
      myEncoding("Orders:"),
      styles: PosStyles(
        bold: true,
      ),
    );

    for (int i = 0; i < receipt.orders!.length; i++) {
      printer.row([
        PosColumn(
          text: myEncoding('id: '),
          width: 4,
        ),
        PosColumn(
          text: myEncoding("#${receipt.orders![i].id}"),
          width: 8,
        )
      ]);
      printer.row([
        PosColumn(
          text: myEncoding('slug: '),
          width: 4,
        ),
        PosColumn(
          text: myEncoding("${receipt.orders![i].slug}"),
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
      printer.row([
        PosColumn(
          text: myEncoding('Adresse: '),
          width: 4,
        ),
        PosColumn(
          text: myEncoding(String.fromCharCodes(chunks[0])),
          width: 8,
        )
      ]);
      for (var i = 1; i < chunks.length; i++) {
        printer.row([
          PosColumn(
            text: myEncoding(' '),
            width: 4,
          ),
          PosColumn(
            text: myEncoding(String.fromCharCodes(chunks[i])),
            width: 8,
          )
        ]);
      }

      printer.row([
        PosColumn(
          text: myEncoding('Total price: '),
          width: 6,
        ),
        PosColumn(
          text: myEncoding("${receipt.orders![i].totalPrice}"),
          width: 6,
        )
      ]);

      printer.row([
        PosColumn(
          text: myEncoding('Delivery price: '),
          width: 6,
        ),
        PosColumn(
          text: myEncoding("${receipt.orders![i].deliveryPrice}"),
          width: 6,
        )
      ]);

      printer.row([
        PosColumn(
          text: myEncoding('Order Ended at: '),
          width: 6,
        ),
        PosColumn(
          text: myEncoding(
              formatter.format(DateTime.parse(receipt.orders![i].endedAt!))),
          width: 6,
        )
      ]);

      printer.row([
        PosColumn(
          text: myEncoding('Payment type: '),
          width: 6,
        ),
        PosColumn(
          text: myEncoding(
              receipt.orders![i].paymentType == 1 ? "Cash" : "Paypal"),
          width: 6,
        )
      ]);

      if (i != receipt.orders!.length - 1) printer.hr(ch: "-");
    }

    printer.hr(ch: "=");
    printer.row([
      PosColumn(
        text: myEncoding('Total Cash: '),
        width: 6,
      ),
      PosColumn(
        text: myEncoding("${receipt.sumCash}"),
        width: 6,
      )
    ]);
    printer.row([
      PosColumn(
        text: myEncoding('Total Paypal: '),
        width: 6,
      ),
      PosColumn(
        text: myEncoding("${receipt.sumPaypal ?? 0.0}"),
        width: 6,
      )
    ]);
    printer.row([
      PosColumn(
        text: myEncoding('Total sum: '),
        width: 6,
      ),
      PosColumn(
        text: myEncoding("${receipt.sumTotal}"),
        width: 6,
      )
    ]);
    printer.emptyLines(2);
  }

  Future<void> driverReceipt(Driver receipt) async {
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
      await ticket(receipt, printer);
    }
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
