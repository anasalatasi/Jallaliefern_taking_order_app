import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/login/auth_repository.dart';

import '../form_submission_status.dart';
import 'login_bloc.dart';
import 'login_state.dart';
import 'login_events.dart';

class LoginView extends StatelessWidget {
  final ButtonStyle mystyle =
      ElevatedButton.styleFrom(primary: Color(0xFF9a0404));
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authRepo: context.read<AuthRepository>()),
      child: Scaffold(
        body: _loginForm(),
      ),
    );
  }

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

  Widget _loginForm() => BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionFailed) {
            _showDialog(context, formStatus.exception.toString());
            context.read<LoginBloc>().add(LoginInit());
          }
        },
        child: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _fromTitle(),
                _usernameField(),
                _passwordField(),
                _loginButton(),
              ],
            ),
          ),
        ),
      );

  Widget _loginButton() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: state.formStatus is FormSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    style: mystyle,
                    child: Text('Login'),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        context.read<LoginBloc>().add(LoginSubmitted());
                      }
                    },
                  ));
      },
    );
  }

  Widget _fromTitle() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Text(
          'Jallaliefern Taking Orders App',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w500, fontSize: 30),
        ));
  }

  Widget _passwordField() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your Password',
                ),
                validator: (value) =>
                    state.validPassword ? null : 'password is required',
                onChanged: (value) => context
                    .read<LoginBloc>()
                    .add(PasswordChanged(password: value))));
      },
    );
  }

  Widget _usernameField() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
                decoration: const InputDecoration(
                    labelText: 'username', hintText: 'Enter Your username'),
                validator: (value) =>
                    state.validUsername ? null : 'username is required',
                onChanged: (value) => context
                    .read<LoginBloc>()
                    .add(UsernameChanged(username: value))));
      },
    );
  }
}
