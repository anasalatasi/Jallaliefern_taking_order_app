import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/screens/api_url_screen.dart';
import 'package:jallaliefern_taking_orders_app/screens/login_screen.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/services/login_service.dart';
import '../services/secure_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/api_form/api_form_repository.dart';
import '../auth/api_form/api_form_bloc.dart';
import '../auth/api_form/api_form_state.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ApiFormBloc(apiFormRepo: context.read<ApiFormRepository>()),
      child: BlocBuilder<ApiFormBloc, ApiFormState>(
        buildWhen: (previous, current) =>
            current.formStatus is SubmissionSuccess,
        builder: (context, state) => FutureBuilder(
          future: locator<SecureStorageService>().haskey('api_url'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data
                  ? (FutureBuilder(
                      future: Future.wait([
                        locator<ApiService>().verifyToken(),
                        locator<Restaurant>().init()
                      ]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData)
                          return snapshot.data[0]
                              ? HomeScreen()
                              : LoginScreen();
                        return Scaffold(
                            body: Center(child: CircularProgressIndicator()));
                      }))
                  : ApiUrlScreen();
            } else {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
          },
        ),
      ),
    );
  }
}
