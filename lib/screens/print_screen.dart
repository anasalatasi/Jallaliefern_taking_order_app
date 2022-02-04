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

    () async {
      final profile = await CapabilityProfile.load();
      final paper = (await locator<SecureStorageService>().paper == "58")
          ? PaperSize.mm58
          : PaperSize.mm80;
      printerNetworkManager = NetworkPrinter(paper, profile);
      _ticket = (await locator<SecureStorageService>().paper == "58")
          ? orderReceipt58(profile)
          : orderReceipt80(profile);
      _print();
    }();
  }

  Future<List<int>> orderReceipt58(CapabilityProfile profile) async {
    final Generator ticket = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // final ByteData data = await rootBundle.load('assets/img/rabbit_black.jpg');
    // final Uint8List bytesimg = data.buffer.asUint8List();
    // final Image? image = decodeImage(bytesimg);
    // bytes += ticket.image(image!, align: PosAlign.center);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    bytes += ticket.text(timestamp,
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    bytes += ticket.text(locator<Restaurant>().name!,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true,
        ),
        linesAfter: 1);
    bytes += ticket.textEncoded(
        myEncoding(
            '${locator<Restaurant>().street} ${locator<Restaurant>().buildingNum}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    bytes += ticket.textEncoded(
        myEncoding(
            '${locator<Restaurant>().zipcode}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    bytes += ticket.textEncoded(
        myEncoding('Tel1: ${locator<Restaurant>().phone1 ?? ""}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += ticket.textEncoded(
        myEncoding('Tel2: ${locator<Restaurant>().phone2 ?? ""}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += ticket.textEncoded(
        myEncoding(
            'Webseite: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1),
        linesAfter: 1);
    bytes += ticket.text("${widget.order.count}",
        styles: PosStyles(
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            align: PosAlign.center));
    bytes += ticket.hr(ch: '=');
    if (widget.order.dineTable != null) {
      bytes += ticket.text("Table: ${widget.order.dineTable}",
          styles: PosStyles(
              width: PosTextSize.size1,
              height: PosTextSize.size1,
              align: PosAlign.left));
    }
    bytes += ticket.row([
      PosColumn(
          text: 'Name: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded:
              myEncoding("${widget.order.firstName} ${widget.order.lastName}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);

    if (widget.order.delivery != null) {
      Uint8List tmp;
      if (await widget.order.delivery!.getSection() != null) {
        tmp = myEncoding(
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}, ${(await widget.order.delivery!.getSection())!.name} ${(await widget.order.delivery!.getSection())!.zipCode}");
      } else {
        tmp = myEncoding(
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}");
      }
      List<Uint8List> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      bytes += ticket.row([
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
        bytes += ticket.row([
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
      bytes += ticket.row([
        PosColumn(
            text: 'Lieferpreis: ',
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            text: "${widget.order.deliveryPrice}",
            width: 6,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);
    }
    bytes += ticket.text('Tel: ${widget.order.phone}',
        styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    final String timestamp2 = formatter.format(
        widget.order.serveDateTime ?? DateTime.parse(widget.order.createdAt));

    bytes += ticket.text("Datum: $timestamp2",
        styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += ticket.row([
      PosColumn(
          text: 'Bestell.ID: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "#${widget.order.id}",
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Bestell.Slug: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "${widget.order.slug}",
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Bestellung: ',
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "${widget.order.getType()}",
          width: 6,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    bytes += ticket.hr(ch: "=");

    for (int i = 0; i < (await widget.order.items).length; i++) {
      var item = (await widget.order.items)[i];
      var tmp = myEncoding(
          "${item.quantity}x ${item.mealObject.name}${(item.sizeObject == null) ? "" : (" - " + item.sizeObject!.name)} ${item.totalPrice}");
      List<Uint8List> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      for (var i = 0; i < chunks.length; i++) {
        bytes += ticket.row([
          PosColumn(
              textEncoded: chunks[i],
              width: 12,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1))
        ]);
      }
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        bytes += ticket.row([
          PosColumn(width: 1, styles: PosStyles()),
          PosColumn(
              textEncoded: myEncoding('+${itemAddon.addonObject.name}'),
              width: 7,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1)),
          PosColumn(
              text: '${itemAddon.totalPrice}',
              width: 4,
              styles: PosStyles(
                  align: PosAlign.right,
                  height: PosTextSize.size1,
                  width: PosTextSize.size1)),
        ]);
      }
      if (item.notes != null && item.notes!.length > 0) {
        bytes += ticket.text('Anmerkung:',
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
        bytes += ticket.textEncoded(myEncoding(item.notes!),
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
      }
      if (i < (await widget.order.items).length - 1) {
        bytes += ticket.hr(ch: "-");
      }
    }

    if ((await widget.order.giftChoicess).length > 0) {
      bytes += ticket.hr(ch: '=');
      bytes += ticket.text('Gifts:',
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          ));
      for (int i = 0; i < (await widget.order.giftChoicess).length; i++) {
        bytes += ticket.text((await widget.order.giftChoicess)[i].description!,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
      }
    }

    bytes += ticket.hr(ch: '=');

    bytes += ticket.row([
      PosColumn(
          width: 12,
          text:
              "Price Before Discounts: ${(widget.order.beforePrice)!.toStringAsFixed(2)}",
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);

    bytes += ticket.row([
      PosColumn(
          width: 12,
          text:
              "Discount: ${((widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice! == 0 ? 0 : -1) * (widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice!)).toStringAsFixed(2)}",
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);

    if (widget.order.type == 1) {
      bytes += ticket.row([
        PosColumn(
            width: 12,
            text:
                "Liefern Preis: ${(widget.order.deliveryPrice!).toStringAsFixed(2)}",
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      ]);
    }
    bytes += ticket.hr(ch: '=');
    bytes += ticket.row([
      PosColumn(
          text: 'Gesamtpreis',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
      PosColumn(
          text: '${widget.order.totalPrice}${locator<Restaurant>().currency}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    if (widget.order.notes != null && widget.order.notes!.length > 0) {
      bytes += ticket.text('Anmerkung:',
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
      bytes += ticket.textEncoded(myEncoding(widget.order.notes!),
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
    }

    bytes += ticket.feed(2);
    bytes += ticket.text('Danke!',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // ticket.qrcode('example.com');

    bytes += ticket.feed(2);
    bytes += ticket.cut();
    return bytes;
  }

  Future<List<int>> orderReceipt80(CapabilityProfile profile) async {
    final Generator ticket = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // final ByteData data = await rootBundle.load('assets/img/rabbit_black.jpg');
    // final Uint8List bytesimg = data.buffer.asUint8List();
    // final Image? image = decodeImage(bytesimg);
    // bytes += ticket.image(image!, align: PosAlign.center);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    bytes += ticket.text(timestamp,
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    bytes += ticket.text(locator<Restaurant>().name!,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true,
        ),
        linesAfter: 1);
    bytes += ticket.textEncoded(
        myEncoding(
            '${locator<Restaurant>().street} ${locator<Restaurant>().buildingNum} ${locator<Restaurant>().zipcode}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    bytes += ticket.textEncoded(
        myEncoding('Tel1: ${locator<Restaurant>().phone1 ?? ""}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += ticket.textEncoded(
        myEncoding('Tel2: ${locator<Restaurant>().phone2 ?? ""}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += ticket.textEncoded(
        myEncoding(
            'Webseite: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1),
        linesAfter: 1);
    bytes += ticket.text("${widget.order.count}",
        styles: PosStyles(
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            align: PosAlign.center));
    bytes += ticket.hr(ch: '=');
    if (widget.order.dineTable != null) {
      bytes += ticket.text("Table: ${widget.order.dineTable}",
          styles: PosStyles(
              width: PosTextSize.size1,
              height: PosTextSize.size1,
              align: PosAlign.left));
    }
    bytes += ticket.row([
      PosColumn(
          text: 'Name: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          textEncoded:
              myEncoding("${widget.order.firstName} ${widget.order.lastName}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);

    if (widget.order.delivery != null) {
      Uint8List tmp;
      if (await widget.order.delivery!.getSection() != null) {
        tmp = myEncoding(
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}, ${(await widget.order.delivery!.getSection())!.name} ${(await widget.order.delivery!.getSection())!.zipCode}");
      } else {
        tmp = myEncoding(
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}");
      }
      List<Uint8List> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.sublist(i, min(tmp.length, i + 32)));
      }
      bytes += ticket.row([
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
        bytes += ticket.row([
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
      bytes += ticket.row([
        PosColumn(
            text: 'Lieferpreis: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            text: "${widget.order.deliveryPrice}",
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
      ]);
    }
    bytes += ticket.text('Tel: ${widget.order.phone}',
        styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    final String timestamp2 = formatter.format(
        widget.order.serveDateTime ?? DateTime.parse(widget.order.createdAt));

    bytes += ticket.text("Datum: $timestamp2",
        styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += ticket.row([
      PosColumn(
          text: 'Bestell.ID: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "#${widget.order.id}",
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Bestell.Slug: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "${widget.order.slug}",
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Bestellung: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "${widget.order.getType()}",
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1))
    ]);
    bytes += ticket.hr(ch: "=");

    for (int i = 0; i < (await widget.order.items).length; i++) {
      var item = (await widget.order.items)[i];
      bytes += ticket.row([
        PosColumn(
            text: '${item.quantity}x',
            width: 1,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        (item.sizeObject == null)
            ? PosColumn(
                textEncoded: myEncoding('${item.mealObject.name}'),
                width: 9,
                styles: PosStyles(
                    height: PosTextSize.size1, width: PosTextSize.size1))
            : PosColumn(
                textEncoded: myEncoding(
                    '${item.mealObject.name} - ${item.sizeObject!.name}'),
                width: 9,
                styles: PosStyles(
                    height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            text: '${item.totalPrice}',
            width: 2,
            styles: PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1)),
      ]);
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        bytes += ticket.row([
          PosColumn(width: 3, styles: PosStyles()),
          PosColumn(
              textEncoded: myEncoding('+${itemAddon.addonObject.name}'),
              width: 7,
              styles: PosStyles(
                  height: PosTextSize.size1, width: PosTextSize.size1)),
          PosColumn(
              text: '${itemAddon.totalPrice}',
              width: 2,
              styles: PosStyles(
                  align: PosAlign.right,
                  height: PosTextSize.size1,
                  width: PosTextSize.size1)),
        ]);
      }
      if (item.notes != null && item.notes!.length > 0) {
        bytes += ticket.text('Anmerkung:',
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
        bytes += ticket.textEncoded(myEncoding(item.notes!),
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
      }
      if (i < (await widget.order.items).length - 1) {
        bytes += ticket.hr(ch: "-");
      }
    }

    if ((await widget.order.giftChoicess).length > 0) {
      bytes += ticket.hr(ch: '=');
      bytes += ticket.text('Gifts:',
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          ));
      for (int i = 0; i < (await widget.order.giftChoicess).length; i++) {
        bytes += ticket.text((await widget.order.giftChoicess)[i].description!,
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
      }
    }

    bytes += ticket.hr(ch: '=');

    bytes += ticket.row([
      PosColumn(
          width: 10,
          text: "Price Before Discounts: ",
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          width: 2,
          text: "${(widget.order.beforePrice)!.toStringAsFixed(2)}",
          styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1))
    ]);

    bytes += ticket.row([
      PosColumn(
          width: 10,
          text: "Discount: ",
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          width: 2,
          text:
              "${((widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice! == 0 ? 0 : -1) * (widget.order.beforePrice! - widget.order.totalPrice + widget.order.deliveryPrice!)).toStringAsFixed(2)}",
          styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1))
    ]);

    if (widget.order.type == 1) {
      bytes += ticket.row([
        PosColumn(
            width: 10,
            text: "Liefern Preis: ",
            styles:
                PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
        PosColumn(
            width: 2,
            text: "${(widget.order.deliveryPrice!).toStringAsFixed(2)}",
            styles: PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1))
      ]);
    }
    bytes += ticket.hr(ch: '=');
    bytes += ticket.row([
      PosColumn(
          text: 'Gesamtpreis',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
      PosColumn(
          text: '${widget.order.totalPrice}${locator<Restaurant>().currency}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    if (widget.order.notes != null && widget.order.notes!.length > 0) {
      bytes += ticket.text('Anmerkung:',
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
      bytes += ticket.textEncoded(myEncoding(widget.order.notes!),
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
    }

    bytes += ticket.feed(2);
    bytes += ticket.text('Danke!',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // ticket.qrcode('example.com');

    bytes += ticket.feed(2);
    bytes += ticket.cut();
    return bytes;
  }

  void _print() async {
    await _ticket;
    try {
      if (await locator<SecureStorageService>().printerIp != null &&
          (await locator<SecureStorageService>().printerIp).length > 1) {
        await printerNetworkManager!.connect(
            await locator<SecureStorageService>().printerIp,
            port: 9100);
      }
      List<int>? tmp = await _ticket;
      int n = await locator<SecureStorageService>().receiptCopies;
      if (await locator<SecureStorageService>().printerIp != null &&
          (await locator<SecureStorageService>().printerIp).length > 1) {
        printerNetworkManager!.rawBytes(tmp!);
        for (int i = 1; i < n; i++) {
          await Future.delayed(Duration(seconds: 5));
          printerNetworkManager!.rawBytes(tmp);
          showToast("$i");
        }
      } else {
        var res = await printerManager.printTicket(tmp!);
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
