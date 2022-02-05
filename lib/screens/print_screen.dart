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
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
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
  PrinterBluetoothManager printerManager =
      locator<PrinterService>().printerManager;
  NetworkPrinter? printerNetworkManager;
  Future<List<int>>? _ticket;

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

  @override
  void initState() {
    super.initState();

    _print();
  }

  Future<void> orderReceipt() async {
    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    SunmiPrinter.text(timestamp, styles: SunmiStyles(align: SunmiAlign.center));
    SunmiPrinter.text(locator<Restaurant>().name!,
        styles: SunmiStyles(
            align: SunmiAlign.center, size: SunmiSize.lg, bold: true));
    SunmiPrinter.text(
        '${locator<Restaurant>().street} ${locator<Restaurant>().buildingNum}',
        styles: SunmiStyles(align: SunmiAlign.center));
    SunmiPrinter.text(
        '${locator<Restaurant>().zipcode}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}',
        styles: SunmiStyles(align: SunmiAlign.center));

    SunmiPrinter.text('Tel1: ${locator<Restaurant>().phone1 ?? ""}',
        styles: SunmiStyles(align: SunmiAlign.center));

    SunmiPrinter.text('Tel2: ${locator<Restaurant>().phone2 ?? ""}',
        styles: SunmiStyles(align: SunmiAlign.center));

    SunmiPrinter.text(
        'Webseite: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}',
        styles: SunmiStyles(align: SunmiAlign.center));

    SunmiPrinter.emptyLines(1);

    SunmiPrinter.text('${widget.order.count}',
        styles: SunmiStyles(align: SunmiAlign.center));

    SunmiPrinter.hr(ch: '=');

    if (widget.order.dineTable != null) {
      SunmiPrinter.text("Table: ${widget.order.dineTable}");
    }

    SunmiPrinter.row(cols: [
      SunmiCol(text: "Name: ", width: 4),
      SunmiCol(
          text: "${widget.order.firstName} ${widget.order.lastName}", width: 8)
    ]);

    if (widget.order.delivery != null) {
      List<int> tmp;
      if (await widget.order.delivery!.getSection() != null) {
        tmp =
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}, ${(await widget.order.delivery!.getSection())!.name} ${(await widget.order.delivery!.getSection())!.zipCode}"
                .codeUnits;
      } else {
        tmp =
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}"
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
          text: 'Lieferpreis: ',
          width: 6,
        ),
        SunmiCol(
          text: "${widget.order.deliveryPrice}",
          width: 6,
        )
      ]);
    }

    SunmiPrinter.text('Tel: ${widget.order.phone}');
    final String timestamp2 = formatter.format(
        widget.order.serveDateTime ?? DateTime.parse(widget.order.createdAt));

    SunmiPrinter.text("Datum: $timestamp2");
    SunmiPrinter.row(cols: [
      SunmiCol(text: 'Bestell.ID: ', width: 6),
      SunmiCol(text: "#${widget.order.id}", width: 6)
    ]);

    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Bestell.Slug: ',
        width: 6,
      ),
      SunmiCol(
        text: "${widget.order.slug}",
        width: 6,
      )
    ]);
    SunmiPrinter.row(cols: [
      SunmiCol(
        text: 'Bestellung: ',
        width: 6,
      ),
      SunmiCol(
        text: "${widget.order.getType()}",
        width: 6,
      )
    ]);
    SunmiPrinter.hr(ch: "=");

    for (int i = 0; i < (await widget.order.items).length; i++) {
      var item = (await widget.order.items)[i];
      var tmp =
          "${item.quantity}x ${item.mealObject.name}${(item.sizeObject == null) ? "" : (" - " + item.sizeObject!.name)} ${item.totalPrice}"
              .codeUnits;
      List<List<int>> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      for (var i = 0; i < chunks.length; i++) {
        SunmiPrinter.row(cols: [
          SunmiCol(
            text: String.fromCharCodes(chunks[i]),
            width: 12,
          )
        ]);
      }
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        SunmiPrinter.row(cols: [
          SunmiCol(width: 1),
          SunmiCol(
            text: '+${itemAddon.addonObject.name}',
            width: 7,
          ),
          SunmiCol(
            text: '${itemAddon.totalPrice}',
            width: 4,
            align: SunmiAlign.right,
          )
        ]);
      }
      if (item.notes != null && item.notes!.length > 0) {
        SunmiPrinter.text('Anmerkung:');
        SunmiPrinter.text(item.notes!);
      }
      if (i < (await widget.order.items).length - 1) {
        SunmiPrinter.hr(ch: "-");
      }
    }

    if ((await widget.order.giftChoicess).length > 0) {
      SunmiPrinter.hr(ch: '=');
      SunmiPrinter.text('Gifts:',
          styles: SunmiStyles(
            bold: true,
          ));
      for (int i = 0; i < (await widget.order.giftChoicess).length; i++) {
        SunmiPrinter.text((await widget.order.giftChoicess)[i].description!);
      }
    }

    SunmiPrinter.hr(ch: '=');

    SunmiPrinter.row(cols: [
      SunmiCol(
        width: 12,
        text:
            "Price Before Discounts: ${(widget.order.beforePrice)!.toStringAsFixed(2)}",
      ),
    ]);

    SunmiPrinter.row(cols: [
      SunmiCol(
        width: 12,
        text:
            "Discount: ${((widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice! == 0 ? 0 : -1) * (widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice!)).toStringAsFixed(2)}",
      ),
    ]);

    if (widget.order.type == 1) {
      SunmiPrinter.row(cols: [
        SunmiCol(
          width: 12,
          text:
              "Liefern Preis: ${(widget.order.deliveryPrice!).toStringAsFixed(2)}",
        ),
      ]);
    }
    SunmiPrinter.hr(ch: "=");
    SunmiPrinter.row(bold: true, cols: [
      SunmiCol(
        text: 'Gesamtpreis',
        width: 6,
      ),
      SunmiCol(
        text: '${widget.order.totalPrice}${locator<Restaurant>().currency}',
        width: 6,
        align: SunmiAlign.right,
      ),
    ]);

    SunmiPrinter.hr(ch: '=', linesAfter: 1);

    if (widget.order.notes != null && widget.order.notes!.length > 0) {
      SunmiPrinter.text('Anmerkung:');
      SunmiPrinter.text(widget.order.notes!);
    }

    SunmiPrinter.emptyLines(2);
    SunmiPrinter.text('Danke!',
        styles: SunmiStyles(align: SunmiAlign.center, bold: true));
    SunmiPrinter.emptyLines(2);
  }

  void _print() async {
    await orderReceipt();
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
