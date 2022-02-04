import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:oktoast/oktoast.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PrinterBluetoothManager printerManager =
      locator<PrinterService>().printerManager;
  TextEditingController? _controller, _controllerip, _controllerpaper;
  List<PrinterBluetooth> _devices = [];
  @override
  void initState() {
    super.initState();
    printerManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      _controller = TextEditingController(
          text:
              (await locator<SecureStorageService>().receiptCopies).toString());
      _controllerip = TextEditingController(
          text: (await locator<SecureStorageService>().printerIp).toString());
      _controllerpaper = TextEditingController(
          text: (await locator<SecureStorageService>().paper).toString());
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

  void _connectPrinter(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);
    // locator<SecureStorageService>().write('printer_ip', printer.address);
    showToast("Printer Selected");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Kcolor,
        title: Text("Druckereinstellungen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Row(children: [
            //   Text(
            //     "Encoding: ",
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            //   ),
            //   DropdownButton(
            //       value: locator<PrinterService>().codetable,
            //       elevation: 16,
            //       onChanged: (PosCodeTable? newValue) {
            //         setState(() {
            //           locator<PrinterService>().codetable = newValue;
            //         });
            //       },
            //       items: locator<PrinterService>().codetablelist),
            // ]),
            // SizedBox(width: 5, height: 5),
            Row(children: [
              Text(
                "Printer IP:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ]),
            SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Printer IP",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String str) async {
                      if (str == "") return;
                      await locator<SecureStorageService>()
                          .write("printer_ip", str);
                    },
                    controller: _controllerip,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(children: [
              Text(
                "Anzahl der Kopien:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ]),
            SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Anzahl der Kopien",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (String str) async {
                      if (str == "") return;
                      await locator<SecureStorageService>()
                          .write("receipt_copies", str);
                    },
                    controller: _controller,
                    maxLength: 1,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "paper size",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (String str) async {
                      if (str == "") return;
                      await locator<SecureStorageService>().write("paper", str);
                    },
                    controller: _controllerpaper,
                    maxLength: 2,
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            Row(children: [
              Text(
                "Drucker auswählen:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ]),
            Expanded(
              child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => _connectPrinter(_devices[index]),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(_devices[index].name ?? ''),
                                      Text(_devices[index].address ?? ""),
                                      Text(
                                        'Drucker anschließen',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
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
            ),
          ],
        ),
      ),
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
