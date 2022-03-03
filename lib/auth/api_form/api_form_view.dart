import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_events.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_state.dart';
import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';
import '../../Constants.dart';

class ApiFormView extends StatelessWidget {
  final _formkey = GlobalKey<FormState>();

  final ButtonStyle mystyle =
      ElevatedButton.styleFrom(primary: Color(0xfff86011));

  Future<void> _showDialog(BuildContext context, String msg) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget _apiForm() => BlocListener<ApiFormBloc, ApiFormState>(
        listenWhen: (previous, current) =>
            current.formStatus is SubmissionFailed,
        listener: (context, state) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _fromTitle(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _apiUrlField(),
                    SizedBox(
                      height: 16,
                    ),
                    _saveButton()
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _apiUrlField() =>
      BlocBuilder<ApiFormBloc, ApiFormState>(builder: (context, state) {
        return Card(
          elevation: 5,
          child: TextFormField(
              decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.web,
                    color: Kcolor,
                  ),
                  border:
                      OutlineInputBorder(borderSide: BorderSide(color: Kcolor)),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: Kcolor)),
                  labelStyle: TextStyle(
                    color: Kcolor,
                  ),
                  labelText: 'Website URL :',
                  hintText: 'http://example.com'),
              validator: (value) =>
                  state.validApiUrl ? null : 'url is not valid',
              onChanged: (value) => context
                  .read<ApiFormBloc>()
                  .add(ApiUrlChanged(apiUrl: value))),
        );
      });
  Widget _fromTitle() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Text(
          'OrderSet Order manager',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Kcolor, fontWeight: FontWeight.w500, fontSize: 30),
        ));
  }

  Widget _saveButton() =>
      BlocBuilder<ApiFormBloc, ApiFormState>(builder: (context, state) {
        return state.formStatus is FormSubmitting
            ? CircularProgressIndicator()
            : ElevatedButton(
                style: mystyle,
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    context.read<ApiFormBloc>().add(FormSubmitted());
                  }
                },
                child: Text('Save'));
      });
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _apiForm());
  }
}
