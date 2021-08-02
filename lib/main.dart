import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import 'screens/welcome_screen.dart';
import 'utils/service_locator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void registerNotification() async {
  await Firebase.initializeApp();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('your channel id', 'your channel name',
              'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, message.notification!.title, message.notification!.body, platformChannelSpecifics,
          payload: 'item x');
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerNotification();
  setupLocator();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
          home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => ApiFormRepository()),
        ],
        child: WelcomeScreen(),
      ));
}
