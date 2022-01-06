import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/screens/close_screen.dart';
import 'package:jallaliefern_taking_orders_app/screens/drivers_screen.dart';
import 'package:jallaliefern_taking_orders_app/screens/pages/Finished_page.dart';
import 'package:jallaliefern_taking_orders_app/screens/pages/Preorder_page.dart';
import 'package:jallaliefern_taking_orders_app/screens/pages/Ready_page.dart';
import 'package:jallaliefern_taking_orders_app/screens/pages/table_reservation_page.dart';
import 'package:jallaliefern_taking_orders_app/screens/search_screen.dart';
import 'package:jallaliefern_taking_orders_app/screens/settings_screen.dart';
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/custom_search_delegate.dart';
import 'login_screen.dart';
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
    PreorderPage(),
    TableReservationPage()
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
          BottomNavigationBarItem(
              icon: Icon(Icons.request_page_outlined), label: 'Preorder'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Table'),
        ],
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100.0,
              child: DrawerHeader(
                  child: Center(
                    child: Text(
                      'Taking Orders App',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  decoration: BoxDecoration(color: Color(0xFF9a0404)),
                  margin: EdgeInsets.all(0.0),
                  padding: EdgeInsets.all(0.0)),
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.lock),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text("Super close", style: TextStyle(fontSize: 20)),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CloseScreen()));
              },
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.print),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child:
                        Text("Print Drivers", style: TextStyle(fontSize: 20)),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DriversScreen()));
              },
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.settings),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text("Printer settings",
                        style: TextStyle(fontSize: 20)),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.logout),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text("Logout", style: TextStyle(fontSize: 20)),
                  )
                ],
              ),
              onTap: () {
                locator<SecureStorageService>().write("access_token", "");
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context, delegate: CustomSearchDelegate());
                }),
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
