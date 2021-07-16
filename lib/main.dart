import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(MaterialApp(
    home: RepositoryProvider(
        create: (context) => ApiFormRepository(), child: WelcomeScreen()),
  ));
}
