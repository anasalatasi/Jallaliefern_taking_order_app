import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:oktoast/oktoast.dart';
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import '../models/order.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';

class PrintScreen extends StatefulWidget {
  final Order order;

  PrintScreen({required this.order});

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();

    printerManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
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
    ticket.text(timestamp, styles: PosStyles(align: PosAlign.center));

    ticket.text(locator<Restaurant>().name!,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ticket.text(
        '${locator<Restaurant>().street}, ${locator<Restaurant>().city}, ${locator<Restaurant>().country}',
        styles: PosStyles(align: PosAlign.center));

    ticket.text('Tel1: ${locator<Restaurant>().phone1 ?? ""}',
        styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel2: ${locator<Restaurant>().phone2 ?? ""}',
        styles: PosStyles(align: PosAlign.center));

    ticket.text(
        'Web: ${Uri.parse(await locator<SecureStorageService>().apiUrl).host}',
        styles: PosStyles(align: PosAlign.center),
        linesAfter: 1);
    ticket.hr(ch: '=');
    ticket.row([
      PosColumn(text: 'Full Name:', width: 4),
      PosColumn(
          text: "${widget.order.firstName} ${widget.order.lastName}", width: 8)
    ]);
    ticket.row([
      PosColumn(text: 'Order ID:', width: 4),
      PosColumn(text: "#${widget.order.id}", width: 8)
    ]);
    ticket.row([
      PosColumn(text: 'Order Slug:', width: 4),
      PosColumn(text: "${widget.order.slug}", width: 8)
    ]);
    if (widget.order.delivery != null) {
      if (await widget.order.delivery!.getSection() != null) {
        ticket.row([
          PosColumn(text: 'Full Address:', width: 4),
          PosColumn(
              text:
                  "${(await widget.order.delivery!.getZone())!.name}, ${(await widget.order.delivery!.getSection())!.name}, ${widget.order.delivery!.address}",
              width: 8)
        ]);
      } else {
        ticket.row([
          PosColumn(text: 'Full Address:', width: 4),
          PosColumn(
              text:
                  "${(await widget.order.delivery!.getZone())!.name}, ${widget.order.delivery!.address}",
              width: 8)
        ]);
      }
    }
    ticket.text('Tel1: ${widget.order.phone}',
        styles: PosStyles(align: PosAlign.center));

    ticket.hr();

    for (int i = 0; i < widget.order.items.length; i++) {
      var item = widget.order.items[i];
      ticket.row([
        PosColumn(text: '${item.quantity}x', width: 1),
        (await item.getMealSize() == null)
            ? PosColumn(text: '${(await item.getMeal())!.name}', width: 9)
            : PosColumn(
                text:
                    '${(await item.getMeal())!.name} - ${(await item.getMealSize())!.name}',
                width: 9),
        PosColumn(
            text: '${item.totalPrice}',
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
      ]);
      for (int j = 0; j < item.addons!.length; j++) {
        var itemAddon = item.addons![j];
        ticket.row([
          PosColumn(width: 3),
          PosColumn(text: '>${(await itemAddon.getAddon())!.name}', width: 7),
          PosColumn(
              text: '${itemAddon.totalPrice}',
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
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
          )),
      PosColumn(
          text: '${widget.order.totalPrice}${locator<Restaurant>().currency}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

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

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    const PaperSize paper = PaperSize.mm80;
    final PosPrintResult res =
        await printerManager.printTicket(await orderReceipt(paper));

    showToast(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Kcolor,
        title: Text("Print Order #${widget.order.id}"),
      ),
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _testPrint(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }
}
