import 'dart:io';
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

class PrintScreen extends StatefulWidget {
  final Order order;

  PrintScreen({required this.order});

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  PrinterBluetoothManager printerManager =
      locator<PrinterService>().printerManager;
  Future<Ticket>? _ticket;

  String myEncoding(String str) {
    str = str.replaceAll("Ä", "A");
    str = str.replaceAll("ä", "a");
    str = str.replaceAll("Ö", "O");
    str = str.replaceAll("ö", "o");
    str = str.replaceAll("ü", "u");
    str = str.replaceAll("Ü", "U");
    str = str.replaceAll("ẞ", "SS");
    str = str.replaceAll("ß", "ss");
    return str;
  }

  @override
  void initState() {
    super.initState();
    _ticket = orderReceipt(PaperSize.mm80);
  }

  Future<Ticket> orderReceipt(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);
    if (locator<PrinterService>().codetable != null)
      ticket.setGlobalCodeTable(locator<PrinterService>().codetable);
    // Print image
    // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    //final Uint8List bytes = data.buffer.asUint8List();
    //final Image image = decodeImage(bytes);
    // ticket.image(image);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text(timestamp,
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

    ticket.text(locator<Restaurant>().name!,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size3,
          width: PosTextSize.size3,
        ),
        linesAfter: 1);
    ticket.text(
        myEncoding(
            '${locator<Restaurant>().street} ${locator<Restaurant>().buildingNum} ${locator<Restaurant>().zipcode}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

    ticket.text(myEncoding('Tel1: ${locator<Restaurant>().phone1 ?? ""}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    ticket.text(myEncoding('Tel2: ${locator<Restaurant>().phone2 ?? ""}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    ticket.text(
        myEncoding(
            'Webseite: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}'),
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2),
        linesAfter: 1);
    ticket.hr(ch: '=');
    ticket.row([
      PosColumn(
          text: 'Name: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2)),
      PosColumn(
          text:
              myEncoding("${widget.order.firstName} ${widget.order.lastName}"),
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2))
    ]);

    if (widget.order.delivery != null) {
      String tmp = "";
      if (await widget.order.delivery!.getSection() != null) {
        tmp = myEncoding(
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}, ${(await widget.order.delivery!.getSection())!.name} ${(await widget.order.delivery!.getSection())!.zipCode}");
      } else {
        tmp = myEncoding(
            "${widget.order.delivery!.address} ${widget.order.delivery!.buildingNo}");
      }
      List<String> chunks = [];
      for (var i = 0; i < tmp.length; i += 32) {
        chunks.add(tmp.substring(i, min(tmp.length, i + 32)));
      }
      ticket.row([
        PosColumn(
            text: 'Adresse: ',
            width: 4,
            styles:
                PosStyles(height: PosTextSize.size2, width: PosTextSize.size2)),
        PosColumn(
            text: chunks[0],
            width: 8,
            styles:
                PosStyles(height: PosTextSize.size2, width: PosTextSize.size2))
      ]);
      for (var i = 1; i < chunks.length; i++) {
        ticket.row([
          PosColumn(
              text: ' ',
              width: 4,
              styles: PosStyles(
                  height: PosTextSize.size2, width: PosTextSize.size2)),
          PosColumn(
              text: chunks[i],
              width: 8,
              styles: PosStyles(
                  height: PosTextSize.size2, width: PosTextSize.size2))
        ]);
      }
    }
    ticket.text('Tel: ${widget.order.phone}',
        styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    ticket.row([
      PosColumn(
          text: 'Bestell.ID: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2)),
      PosColumn(
          text: "#${widget.order.id}",
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2))
    ]);
    ticket.row([
      PosColumn(
          text: 'Bestell.Slug: ',
          width: 4,
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2)),
      PosColumn(
          text: "${widget.order.slug}",
          width: 8,
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2))
    ]);
    ticket.hr(ch: "=");

    for (int i = 0; i < (await widget.order.items).length; i++) {
      var item = (await widget.order.items)[i];
      ticket.row([
        PosColumn(
            text: '${item.quantity}x',
            width: 1,
            styles:
                PosStyles(height: PosTextSize.size2, width: PosTextSize.size2)),
        (item.sizeObject == null)
            ? PosColumn(
                text: myEncoding('${item.mealObject.name}'),
                width: 9,
                styles: PosStyles(
                    height: PosTextSize.size2, width: PosTextSize.size2))
            : PosColumn(
                text: myEncoding(
                    '${item.mealObject.name} - ${item.sizeObject!.name}'),
                width: 9,
                styles: PosStyles(
                    height: PosTextSize.size2, width: PosTextSize.size2)),
        PosColumn(
            text: '${item.totalPrice}',
            width: 2,
            styles: PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size2,
                width: PosTextSize.size2)),
      ]);
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        ticket.row([
          PosColumn(width: 3, styles: PosStyles()),
          PosColumn(
              text: myEncoding('>${itemAddon.addonObject.name}'),
              width: 7,
              styles: PosStyles(
                  height: PosTextSize.size2, width: PosTextSize.size2)),
          PosColumn(
              text: '${itemAddon.totalPrice}',
              width: 2,
              styles: PosStyles(
                  align: PosAlign.right,
                  height: PosTextSize.size2,
                  width: PosTextSize.size2)),
        ]);
      }
      if (item.notes != null && item.notes!.length > 0) {
        ticket.text('Anmerkung:',
            styles:
                PosStyles(height: PosTextSize.size2, width: PosTextSize.size2));
        ticket.text(myEncoding(item.notes!),
            styles:
                PosStyles(height: PosTextSize.size2, width: PosTextSize.size2));
      }
      if (i < (await widget.order.items).length - 1) {
        ticket.hr(ch: "-");
      }
    }

    ticket.hr(ch: '=');

    ticket.row([
      PosColumn(
          text: 'Gesamtpreis',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size3,
            width: PosTextSize.size3,
          )),
      PosColumn(
          text: '${widget.order.totalPrice}${locator<Restaurant>().currency}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size3,
            width: PosTextSize.size3,
          )),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);

    if (widget.order.notes != null && widget.order.notes!.length > 0) {
      ticket.text('Anmerkung:',
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2));
      ticket.text(myEncoding(widget.order.notes!),
          styles:
              PosStyles(height: PosTextSize.size2, width: PosTextSize.size2));
    }

    ticket.feed(2);
    ticket.text('Danke!',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

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

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  void _print() async {
    try {
      Ticket? tmp = await _ticket;
      int n = await locator<SecureStorageService>().receiptCopies;
      var res = await printerManager.printTicket(tmp);
      showToast(res.msg);
      for (int i = 1; i < n; i++) {
        await Future.delayed(Duration(seconds: 5));
        await printerManager.printTicket(tmp);
        showToast("$i");
      }
    } catch (c) {
      showToast("Printer not connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Kcolor,
          title: Text("drucken #${widget.order.id}"),
        ),
        body: Center(
          child: FutureBuilder(
              future: _ticket,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ElevatedButton(
                    onPressed: _print, child: Text("drucken"));
              }),
        ),
      ),
    );
  }
}
