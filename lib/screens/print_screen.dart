import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'dart:convert' show utf8;
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
  @override
  void initState() {
    super.initState();
    _ticket = orderReceipt(PaperSize.mm80);
  }

  Future<Ticket> orderReceipt(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    // Print image
    // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    //final Uint8List bytes = data.buffer.asUint8List();
    //final Image image = decodeImage(bytes);
    // ticket.image(image);

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);

    ticket.text(timestamp,
        styles:
            PosStyles(align: PosAlign.center, codeTable: PosCodeTable.westEur));

    ticket.text(locator<Restaurant>().name!,
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            codeTable: PosCodeTable.westEur),
        linesAfter: 1);

    ticket.text(
        String.fromCharCodes(await CharsetConverter.encode("windows1252",
            '${locator<Restaurant>().street}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}')),
        styles:
            PosStyles(align: PosAlign.center, codeTable: PosCodeTable.westEur));

    ticket.text(
        String.fromCharCodes(await CharsetConverter.encode(
            "windows1252", 'Tel1: ${locator<Restaurant>().phone1 ?? ""}')),
        styles:
            PosStyles(align: PosAlign.center, codeTable: PosCodeTable.westEur));
    ticket.text(
        String.fromCharCodes(await CharsetConverter.encode(
            "windows1252", 'Tel2: ${locator<Restaurant>().phone2 ?? ""}')),
        styles:
            PosStyles(align: PosAlign.center, codeTable: PosCodeTable.westEur));

    ticket.text(
        String.fromCharCodes(await CharsetConverter.encode("windows1252",
            'Web: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}')),
        styles:
            PosStyles(align: PosAlign.center, codeTable: PosCodeTable.westEur),
        linesAfter: 1);
    ticket.hr(ch: '=');
    ticket.row([
      PosColumn(
          text: 'Full Name:',
          width: 4,
          styles: PosStyles(codeTable: PosCodeTable.westEur)),
      PosColumn(
          text: String.fromCharCodes(await CharsetConverter.encode(
              "windows1252",
              "${widget.order.firstName} ${widget.order.lastName}")),
          width: 8,
          styles: PosStyles(codeTable: PosCodeTable.westEur))
    ]);
    ticket.row([
      PosColumn(
          text: 'Order ID:',
          width: 4,
          styles: PosStyles(codeTable: PosCodeTable.westEur)),
      PosColumn(
          text: "#${widget.order.id}",
          width: 8,
          styles: PosStyles(codeTable: PosCodeTable.westEur))
    ]);
    ticket.row([
      PosColumn(
          text: 'Order Slug:',
          width: 4,
          styles: PosStyles(codeTable: PosCodeTable.westEur)),
      PosColumn(
          text: "${widget.order.slug}",
          width: 8,
          styles: PosStyles(codeTable: PosCodeTable.westEur))
    ]);
    if (widget.order.delivery != null) {
      if (await widget.order.delivery!.getSection() != null) {
        ticket.row([
          PosColumn(
              text: 'Full Address:',
              width: 4,
              styles: PosStyles(codeTable: PosCodeTable.westEur)),
          PosColumn(
              text: String.fromCharCodes(await CharsetConverter.encode(
                  "windows1252",
                  "${(await widget.order.delivery!.getZone())!.name}, ${(await widget.order.delivery!.getSection())!.name}, ${widget.order.delivery!.address}")),
              width: 8,
              styles: PosStyles(codeTable: PosCodeTable.westEur))
        ]);
      } else {
        ticket.row([
          PosColumn(
              text: 'Full Address:',
              width: 4,
              styles: PosStyles(codeTable: PosCodeTable.westEur)),
          PosColumn(
              text: String.fromCharCodes(await CharsetConverter.encode(
                  "windows1252",
                  "${(await widget.order.delivery!.getZone())!.name}, ${widget.order.delivery!.address}")),
              width: 8,
              styles: PosStyles(codeTable: PosCodeTable.westEur))
        ]);
      }
    }
    ticket.text('Tel1: ${widget.order.phone}',
        styles:
            PosStyles(align: PosAlign.center, codeTable: PosCodeTable.westEur));

    ticket.hr();

    for (int i = 0; i < widget.order.items.length; i++) {
      var item = widget.order.items[i];
      ticket.row([
        PosColumn(
            text: '${item.quantity}x',
            width: 1,
            styles: PosStyles(codeTable: PosCodeTable.westEur)),
        (await item.getMealSize() == null)
            ? PosColumn(
                text: String.fromCharCodes(await CharsetConverter.encode(
                    "windows1252", '${(await item.getMeal())!.name}')),
                width: 9,
                styles: PosStyles(codeTable: PosCodeTable.westEur))
            : PosColumn(
                text: String.fromCharCodes(await CharsetConverter.encode(
                    "windows1252",
                    '${(await item.getMeal())!.name} - ${(await item.getMealSize())!.name}')),
                width: 9,
                styles: PosStyles(codeTable: PosCodeTable.westEur)),
        PosColumn(
            text: '${item.totalPrice}',
            width: 2,
            styles: PosStyles(
                align: PosAlign.right, codeTable: PosCodeTable.westEur)),
      ]);
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        ticket.row([
          PosColumn(
              width: 3, styles: PosStyles(codeTable: PosCodeTable.westEur)),
          PosColumn(
              text: String.fromCharCodes(await CharsetConverter.encode(
                  "windows1252", '>${(await itemAddon.getAddon())!.name}')),
              width: 7,
              styles: PosStyles(codeTable: PosCodeTable.westEur)),
          PosColumn(
              text: '${itemAddon.totalPrice}',
              width: 2,
              styles: PosStyles(
                  align: PosAlign.right, codeTable: PosCodeTable.westEur)),
        ]);
      }
    }

    ticket.hr();

    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
              height: PosTextSize.size2,
              width: PosTextSize.size2,
              codeTable: PosCodeTable.westEur)),
      PosColumn(
          text: '${widget.order.totalPrice}${locator<Restaurant>().currency}',
          width: 6,
          styles: PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
              codeTable: PosCodeTable.westEur)),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            codeTable: PosCodeTable.westEur));

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
      final PosPrintResult res =
          await printerManager.printTicket(await _ticket);
      showToast(res.msg);
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
          title: Text("Print Order #${widget.order.id}"),
        ),
        body: Center(
          child: FutureBuilder(
              future: _ticket,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ElevatedButton(
                    onPressed: _print, child: Text("PRINT RECEIPT"));
              }),
        ),
      ),
    );
  }
}
