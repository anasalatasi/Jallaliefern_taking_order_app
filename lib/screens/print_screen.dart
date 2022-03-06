import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart' as PosBluetooth;
import 'package:flutter/material.dart' hide Image;
import 'dart:convert' show Utf8Encoder, utf8;
import 'package:oktoast/oktoast.dart';
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import '../models/order.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:charset_converter/charset_converter.dart';
import 'dart:typed_data';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:image/image.dart';
import 'package:flutter_sunmi_printer/flutter_sunmi_printer.dart';

class PrintScreen extends StatefulWidget {
  final Order order;

  PrintScreen({required this.order});

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
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

  @override
  void initState() {
    super.initState();
    _print();
  }

  Future<void> orderReceipt(NetworkPrinter printer) async {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    printer.text(myEncoding(timestamp),
        styles: PosStyles(align: PosAlign.center));
    printer.text(myEncoding(locator<Restaurant>().name!),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true));
    printer.text(
        myEncoding(
            '${locator<Restaurant>().street} ${locator<Restaurant>().buildingNum}'),
        styles: PosStyles(align: PosAlign.center));
    printer.text(
        myEncoding(
            '${locator<Restaurant>().zipcode}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}'),
        styles: PosStyles(align: PosAlign.center));

    printer.text(myEncoding('Tel1: ${locator<Restaurant>().phone1 ?? ""}'),
        styles: PosStyles(align: PosAlign.center));

    printer.text(myEncoding('Tel2: ${locator<Restaurant>().phone2 ?? ""}'),
        styles: PosStyles(align: PosAlign.center));

    printer.text(
        myEncoding(
            'Webseite: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}'),
        styles: PosStyles(align: PosAlign.center));

    printer.emptyLines(1);

    printer.text(myEncoding('${widget.order.count}'),
        styles: PosStyles(align: PosAlign.center));

    printer.text(myEncoding("${widget.order.slug}"),
        styles: PosStyles(align: PosAlign.center, bold: true));

    printer.hr(ch: '=');

    if (widget.order.dineTable != null) {
      printer.text(myEncoding("Table: ${widget.order.dineTable}"));
    }

    printer.text(
        myEncoding('${widget.order.firstName} ${widget.order.lastName}'),
        styles: PosStyles(
          bold: true,
        ));

    // printer.row([
    //   PosColumn(text: myEncoding("Name: ", width: 4),
    //   PosColumn(
    //       text: myEncoding("${widget.order.firstName} ${widget.order.lastName}", width: 8)
    // ]);

    if (widget.order.delivery != null) {
      printer.text(myEncoding(
          "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}"));
      if (await widget.order.delivery!.getSection() != null) {
        printer.text(myEncoding(
            "${(await widget.order.delivery!.getSection())!.name} ${(await widget.order.delivery!.getSection())!.zipCode}"));
      }

      // printer.row([
      //   PosColumn(
      //     text: myEncoding('Lieferpreis: ',
      //     width: 6,
      //   ),
      //   PosColumn(
      //     text: myEncoding("${widget.order.deliveryPrice}",
      //     width: 6,
      //   )
      // ]);
    }

    printer.text(myEncoding('${widget.order.phone}'));
    // final String timestamp2 = formatter.format(
    //     widget.order.serveDateTime ?? DateTime.parse(widget.order.createdAt));

    // printer.text(myEncoding("Datum: $timestamp2");
    // printer.row([
    //   PosColumn(text: myEncoding('Bestell.ID: ', width: 6),
    //   PosColumn(text: myEncoding("#${widget.order.id}", width: 6)
    // ]);

    // printer.row([
    //   PosColumn(
    //     text: myEncoding('Bestell.Slug: ',
    //     width: 6,
    //   ),
    //   PosColumn(
    //     text: myEncoding("${widget.order.slug}",
    //     width: 6,
    //   )
    // ]);
    if (widget.order.type == 2)
      printer.text(myEncoding("${widget.order.getType()}"));
    printer.hr(ch: "=");

    for (int i = 0; i < (await widget.order.items).length; i++) {
      var item = (await widget.order.items)[i];
      printer.text(myEncoding("${await item.mealObject.getCategoryName()}"),
          styles: PosStyles(bold: true));
      var tmp =
          "${item.quantity}x ${item.mealObject.name}${(item.sizeId == null) ? "" : (" (" + item.sizeObject!.name + ")")} ${item.totalPrice}"
              .codeUnits;
      List<List<int>> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      for (var i = 0; i < chunks.length; i++) {
        printer.row(
          [
            PosColumn(
                text: myEncoding(String.fromCharCodes(chunks[i])),
                width: 12,
                styles: PosStyles(bold: true))
          ],
        );
      }
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        printer.row([
          PosColumn(width: 1),
          PosColumn(
            text: myEncoding('+${itemAddon.addonObject.name}'),
            width: 7,
          ),
          PosColumn(
            text: myEncoding('${itemAddon.totalPrice}'),
            width: 4,
            styles: PosStyles(align: PosAlign.right),
          )
        ]);
      }
      if (item.notes != null && item.notes!.length > 0) {
        printer.text(myEncoding('Anmerkung:'));
        printer.text(myEncoding(item.notes!));
      }
      if (i < (await widget.order.items).length - 1) {
        printer.hr(ch: "-");
      }
    }

    if ((await widget.order.giftChoicess).length > 0) {
      printer.hr(ch: '=');
      printer.text(myEncoding('Gifts:'),
          styles: PosStyles(
            bold: true,
          ));
      for (int i = 0; i < (await widget.order.giftChoicess).length; i++) {
        printer.text(
            myEncoding((await widget.order.giftChoicess)[i].description!));
      }
    }

    printer.hr(ch: '=');

    if (widget.order.payment.type == 1) {
      printer.text(myEncoding("Bestellung wird Bar bezahlt"),
          styles: PosStyles(align: PosAlign.center, bold: true));
    } else if (widget.order.payment.type == 2) {
      printer.text(myEncoding("Bestellung wurde online bezahlt"),
          styles: PosStyles(align: PosAlign.center, bold: true));
    }

    if (widget.order.notes != null && widget.order.notes!.length > 0) {
      printer.text(myEncoding('Anmerkung:'));
      printer.text(myEncoding(widget.order.notes!));
    }

    printer.row([
      PosColumn(
        width: 12,
        text: myEncoding(
            "Gesamtpreis: ${(widget.order.beforePrice)!.toStringAsFixed(2)}"),
      ),
    ]);

    printer.row([
      PosColumn(
        width: 12,
        text: myEncoding(
            "Rabatt: -${((widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice! == 0 ? 0 : -1) * (widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice!)).toStringAsFixed(2)}"),
      ),
    ]);

    if (widget.order.type == 1) {
      printer.row([
        PosColumn(
          width: 12,
          text: myEncoding(
              "Lieferkosten: ${(widget.order.deliveryPrice!).toStringAsFixed(2)}"),
        ),
      ]);
    }
    printer.hr(ch: "=");
    printer.row([
      PosColumn(
          text: myEncoding('Total'), width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: myEncoding(
              '${widget.order.totalPrice}${locator<Restaurant>().currency}'),
          width: 6,
          styles: PosStyles(bold: true, align: PosAlign.right)),
    ]);

    printer.hr(ch: '=', linesAfter: 1);

    printer.emptyLines(2);
    printer.text(myEncoding('Dies ist keine Rechnung!'),
        styles: PosStyles(align: PosAlign.center, bold: true));
    printer.emptyLines(2);
    printer.cut();
  }

  void _print() async {
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
      int cnt = await locator<SecureStorageService>().receiptCopies;
      for (int i = 0; i < cnt; i++) {
        await orderReceipt(printer);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Kcolor,
          title: Text("drucken #${widget.order.id}"),
        ),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
