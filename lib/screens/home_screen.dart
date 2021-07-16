import 'package:flutter/material.dart';
import '../page0.dart';
import '../page1.dart';
import '../page2.dart';
import '../page3.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

  final List<Widget> pages = [
  page0(
    key: PageStorageKey('page0'),
  ),
  page1(
    key: PageStorageKey('page1'),
  ),
  
  ];
  int _selectedIndex = 0;
  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.add), label: 'First Page'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Second Page'),
        ],
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          )
        ],
        elevation: 15.0,
        backgroundColor: Color(0xFF9a0404),
        title: Text('Name'),
      ),
      body: PageStorage(bucket: bucket,child: pages[_selectedIndex],),
      drawer: Drawer(
        child: ListView(
          children: [],
        ),
      ),
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.auto_fix_high_outlined),
      ),
    );
  }
}
