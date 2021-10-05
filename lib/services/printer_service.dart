import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

class PrinterService {
  PrinterNetworkManager printerNetworkManager = PrinterNetworkManager();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  PosCodeTable? codetable;
  bool connected = false;
  List<DropdownMenuItem<PosCodeTable>> codetablelist = [
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc437_1"), value: PosCodeTable(0)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("katakana1"), value: PosCodeTable(1)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc850"), value: PosCodeTable(2)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc860_1"), value: PosCodeTable(3)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc863"), value: PosCodeTable(4)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc865"), value: PosCodeTable(5)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("westEur"), value: PosCodeTable(6)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("greek"), value: PosCodeTable(7)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("hebrew1"), value: PosCodeTable(8)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("eastEur"), value: PosCodeTable(9)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("iran1"), value: PosCodeTable(10)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("wpc1252_1"), value: PosCodeTable(16)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc866_2"), value: PosCodeTable(17)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc852_1"), value: PosCodeTable(18)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc858_1"), value: PosCodeTable(19)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("iran2"), value: PosCodeTable(20)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("latvian"), value: PosCodeTable(21)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("arabic"), value: PosCodeTable(22)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pt1511251"), value: PosCodeTable(23)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc747"), value: PosCodeTable(24)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("wpc1257"), value: PosCodeTable(25)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("vietnam"), value: PosCodeTable(27)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc864_1"), value: PosCodeTable(28)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc1001_1"), value: PosCodeTable(29)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("uigur"), value: PosCodeTable(30)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("hebrew2"), value: PosCodeTable(31)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("israel"), value: PosCodeTable(32)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc437_2"), value: PosCodeTable(50)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("katakana2"), value: PosCodeTable(51)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc437_3"), value: PosCodeTable(52)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc858_2"), value: PosCodeTable(53)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc852_2"), value: PosCodeTable(54)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc860_2"), value: PosCodeTable(55)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc866_1"), value: PosCodeTable(59)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc857"), value: PosCodeTable(61)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc862"), value: PosCodeTable(62)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc864_2"), value: PosCodeTable(63)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc737"), value: PosCodeTable(64)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc851"), value: PosCodeTable(65)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc869"), value: PosCodeTable(66)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc928"), value: PosCodeTable(67)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc874"), value: PosCodeTable(70)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("wpc1252_2"), value: PosCodeTable(71)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("wpc1251"), value: PosCodeTable(73)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc3840"), value: PosCodeTable(74)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc3843"), value: PosCodeTable(76)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc3846"), value: PosCodeTable(79)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc1001_2"), value: PosCodeTable(82)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc3011"), value: PosCodeTable(86)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc3012"), value: PosCodeTable(87)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("wp1256"), value: PosCodeTable(92)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("pc720"), value: PosCodeTable(93)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("thai_2"), value: PosCodeTable(96)),
    DropdownMenuItem<PosCodeTable>(
        child: Text("thai_1"), value: PosCodeTable(255)),
  ];
}
