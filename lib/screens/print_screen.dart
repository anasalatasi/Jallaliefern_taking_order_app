import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import '../models/order.dart';
import 'dart:async';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class PrintScreen extends StatefulWidget {
  final Order order;

  PrintScreen({required this.order});

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  // ignore: unused_field
  bool _connected = false;
  // ignore: unused_field
  bool _pressed = false;
  String? pathImage;
  @override
  void initState() {
    super.initState();
    initSavetoPath();
    initPlatformState();
  }

  initSavetoPath() async {
    var response = await http.get(Uri.parse(locator<Restaurant>().logo!));
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    File file = new File(join(documentDirectory.path, 'logo.png'));
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      pathImage = file.path;
    });
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("PLATFORM ERROR");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });
    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? ""),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(_device!).catchError((error) {
            show('error occured while connecting to device');
            print("AAAA $error");
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(this.context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void _testPrint() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        // HEADER
        // bluetooth.printImage(pathImage!);
        bluetooth.printCustom(locator<Restaurant>().name ?? "", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            DateFormat('yyyy-MM-dd - kk:mm').format(DateTime.now()), 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "${locator<Restaurant>().country}, ${locator<Restaurant>().city}, ${locator<Restaurant>().street}",
            1,
            1);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            '${locator<Restaurant>().phone1 ?? ""} - ${locator<Restaurant>().phone2 ?? ""}',
            1,
            1);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            Uri.parse(locator<SecureStorageService>().apiUrl).host, 1, 1);

        bluetooth.printNewLine();
        bluetooth.printCustom("-" * 20, 3, 1);
        bluetooth.printNewLine();

        // Order Details
        bluetooth.printCustom("Order Details", 3, 1);
        bluetooth.printNewLine();

        bluetooth.printCustom("#${widget.order.id}", 2, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "Full Name: ${widget.order.firstName} ${widget.order.lastName}",
            1,
            0);
        if (widget.order.delivery != null) {
          if ((await widget.order.delivery!.getSection()) == null) {
            bluetooth.printCustom(
                "Address: ${(await widget.order.delivery!.getZone())!.name}, ${(await widget.order.delivery!.getSection())!.name}, ${widget.order.delivery!.address}",
                1,
                0);
          } else {
            bluetooth.printCustom(
                "Address: ${(await widget.order.delivery!.getZone())!.name}, ${widget.order.delivery!.address}",
                1,
                0);
          }
          bluetooth.printNewLine();
        }

        bluetooth.printCustom("Phone: ${widget.order.phone}", 1, 0);
        bluetooth.printNewLine();

        // ITEMS
        bluetooth.printCustom("Items:", 3, 1);
        for (int i = 0; i < widget.order.items.length; i++) {
          var item = widget.order.items[i];
          if (item.size != null) {
            bluetooth.printLeftRight(
                "${(await item.getMeal())!.name} - ${item.size!.name} x${item.quantity}",
                "${item.totalPrice} ${locator<Restaurant>().currency}",
                2);
          } else {
            bluetooth.printLeftRight(
                "${(await item.getMeal())!.name} x${item.quantity}",
                "${item.totalPrice} ${locator<Restaurant>().currency}",
                2);
          }

          if (item.addons != null) {
            for (int j = 0; j < item.addons!.length; j++) {
              var itemAddon = item.addons![j];
              bluetooth.printLeftRight(
                  "    >${(await itemAddon.getAddon())!.name}",
                  "${itemAddon.totalPrice} ${locator<Restaurant>().currency}    ",
                  1);
            }
          }
          bluetooth.printNewLine();
        }

        bluetooth.printNewLine();
        bluetooth.printCustom(
            "${widget.order.totalPrice} ${locator<Restaurant>().currency}",
            3,
            2);
        bluetooth.printNewLine();
        bluetooth.paperCut();
      } else {
        show("connect to device first");
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Kcolor,
        title: Text("Print Order #${widget.order.id}"),
      ),
      body: Column(
        children: [
          Row(children: [
            Text('Choose Device: '),
            DropdownButton<BluetoothDevice>(
              value: _device,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (BluetoothDevice? newValue) {
                setState(() {
                  _device = newValue!;
                });
              },
              items: _getDeviceItems(),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _connect, child: Text('Connect')),
              ElevatedButton(onPressed: _testPrint, child: Text('Print')),
            ],
          )
        ],
      ));
}
