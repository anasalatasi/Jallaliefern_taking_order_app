import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_events.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_state.dart';
import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';

class ApiFormView extends StatelessWidget {
  final _formkey = GlobalKey<FormState>();

  Future<void> _showDialog(BuildContext context,String msg) async {
    return showDialog(context:context,builder: (context) {
      return AlertDialog(title: Text('Error'),content: Text(msg),actions: <Widget>[TextButton(child: Text('OK'),onPressed: () {Navigator.of(context).pop();},)],);
    });
  }

  Widget _apiForm() =>
      BlocListener<ApiFormBloc, ApiFormState>(listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is SubmissionFailed) {
          _showDialog(context, formStatus.exception.toString());
          context.read<ApiFormBloc>().add(FormInit());
        }
      },
        child: Form(
            key: _formkey,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_apiUrlField(), _saveButton()])))
      );

  Widget _apiUrlField() =>
      BlocBuilder<ApiFormBloc, ApiFormState>(builder: (context, state) {
        return TextFormField(
            decoration: InputDecoration(
                labelText: 'Website URL:', hintText: 'http://example.com'),
            validator: (value) => state.validApiUrl ? null : 'url is not valid',
            onChanged: (value) =>
                context.read<ApiFormBloc>().add(ApiUrlChanged(apiUrl: value)));
      });

  Widget _saveButton() =>
      BlocBuilder<ApiFormBloc, ApiFormState>(builder: (context, state) {
        return state.formStatus is FormSubmitting
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    context.read<ApiFormBloc>().add(FormSubmitted());
                  }
                },
                child: Text('Save'));
      });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            ApiFormBloc(apiFormRepo: context.read<ApiFormRepository>()),
        child: Scaffold(body: _apiForm()));
  }
}
