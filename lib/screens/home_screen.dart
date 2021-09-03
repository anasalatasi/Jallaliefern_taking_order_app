import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/screens/pages/Finished_page.dart';
import 'package:jallaliefern_taking_orders_app/screens/pages/Ready_page.dart';
import 'package:jallaliefern_taking_orders_app/screens/settings_screen.dart';
import 'pages/New_page.dart';
import 'pages/Inprog_page.dart';
import '../../Constants.dart';

import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

  final List<Widget> pages = [
    NewPage(),
    InProgPage(),
    ReadyPage(),
    FinishedPage(),
  ];
  int _selectedIndex = 0;
  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        selectedItemColor: Kcolor,
        unselectedLabelStyle: TextStyle(color: Colors.black38),
        showUnselectedLabels: true,
        unselectedItemColor: Colors.black38,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.request_page_outlined), label: 'Neu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.watch_later_outlined), label: 'im Gange'),
          BottomNavigationBarItem(
              icon: Icon(Icons.done_rounded), label: 'bereit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.done_all_rounded), label: 'fertig'),
        ],
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            )
          ],
          elevation: 15.0,
          backgroundColor: Color(0xFF9a0404),
          title: Row(children: [
            Text(locator<Restaurant>().name!),
          ])),
      body: PageStorage(
        bucket: bucket,
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.auto_fix_high_outlined),
      // ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String text;
  final Function onTAp;
  final IconData icon;

  const CustomListTile(this.icon, this.onTAp, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide())),
        child: InkWell(
          splashColor: Kcolor,
          onTap: onTAp(),
          child: Container(
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          text,
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                  Icon(Icons.arrow_right)
                ]),
          ),
        ),
      ),
    );
  }
}
