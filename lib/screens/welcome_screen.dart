import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';
import 'package:jallaliefern_taking_orders_app/screens/api_url_screen.dart';
import 'package:jallaliefern_taking_orders_app/screens/login_screen.dart';
import '../secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/api_form/api_form_repository.dart';
import '../auth/api_form/api_form_bloc.dart';
import '../auth/api_form/api_form_state.dart';

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
          future: SecureStorage.haskey('api_url'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data ? LoginScreen() : ApiUrlScreen();
            } else {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
          },
        ),
      ),
    );
  }
}
