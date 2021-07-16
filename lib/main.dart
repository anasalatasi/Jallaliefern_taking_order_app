import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import 'package:jallaliefern_taking_orders_app/auth/login/auth_repository.dart';
import 'screens/welcome_screen.dart';
import 'secure_storage.dart';

void main() {
  runApp(MaterialApp(
      home: MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => ApiFormRepository()),
      RepositoryProvider(create: (context) => AuthRepository())
    ],
    child: WelcomeScreen(),
  )));
}
