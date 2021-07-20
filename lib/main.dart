import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import 'screens/welcome_screen.dart';
import 'utils/service_locator.dart';

void main() {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return MaterialApp(
              home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (context) => ApiFormRepository()),
            ],
            child: WelcomeScreen(),
          ));
        return CircularProgressIndicator();
      });
}
