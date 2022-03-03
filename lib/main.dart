import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import 'package:jallaliefern_taking_orders_app/services/sound_service.dart';
import 'screens/welcome_screen.dart';
import 'utils/service_locator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock/wakelock.dart';

void registerNotification() async {
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getInitialMessage();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      locator<SoundService>().playAlert();
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  registerNotification();
  Wakelock.enable();
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
