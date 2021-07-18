import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/Finished_page.dart';
import 'package:jallaliefern_taking_orders_app/Ready_page.dart';
import '../New_page.dart';
import '../Inprog_page.dart';
import '../../Constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

  final List<Widget> pages = [
  New_Page(
    key: PageStorageKey('New_Page'),
  ),
  InProg_Page(
    key: PageStorageKey('InProg_Page'),
  ),
  Ready_Page(
    key: PageStorageKey('Ready_Page'),
  ),
  Finished_Page(
    key: PageStorageKey('Finished_Page'),
  )
  ];
  int _selectedIndex = 0;
  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        selectedItemColor : Kcolor ,
        unselectedLabelStyle: TextStyle(color: Colors.black38),
        showUnselectedLabels: true,
        unselectedItemColor: Colors.black38,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.request_page_outlined), label: 'New'),
          BottomNavigationBarItem(
              icon: Icon(Icons.watch_later_outlined), label: 'In Progress'),
        BottomNavigationBarItem(
              icon: Icon(Icons.done_rounded),label: 'Ready'),
          BottomNavigationBarItem(
              icon: Icon(Icons.done_all_rounded), label: 'Finished'),
          
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
