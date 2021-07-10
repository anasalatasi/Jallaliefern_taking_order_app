import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 15.0,
          backgroundColor: Color(0xFF9a0404),
          title: Text('Name'),
        ),
        body: Text('Hi'),
        drawer: Drawer(
          child: ListView(
            children: [],
          ),
        ),
      ),
    );
  }
}
