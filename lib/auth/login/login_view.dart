import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/Constants.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/screens/home_screen.dart';
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/exceptions.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import '../form_submission_status.dart';
import 'login_bloc.dart';
import 'login_state.dart';
import 'login_events.dart';
import '../../Constants.dart';

class LoginView extends StatelessWidget {
  final ButtonStyle mystyle =
      ElevatedButton.styleFrom(primary: Color(0xfff86011));
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
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
            _showDialog(
                context,
                formStatus.exception is MyException
                    ? formStatus.exception.toString()
                    : formStatus.exception.toString());
            context.read<LoginBloc>().add(LoginInit());
          } else if (formStatus is SubmissionSuccess) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _formTitle(),
                          _usernameField(),
                          SizedBox(
                            height: 8,
                          ),
                          _passwordField(),
                          SizedBox(
                            height: 8,
                          ),
                          _loginButton(),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ),
      );
  Widget _formTitle() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: locator<Restaurant>().logo != null
              ? FutureBuilder(
                  future: locator<SecureStorageService>().apiUrl,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    var tmp =
                        snapshot.data.substring(0, snapshot.data.length - 5) +
                            locator<Restaurant>().logo!;
                    return Image.network(tmp);
                  })
              : CircularProgressIndicator(),
        ),
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              locator<Restaurant>().name ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w500, fontSize: 20),
            )),
      ],
    );
  }

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

  Widget _passwordField() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Card(
              elevation: 5,
              child: TextFormField(
                  obscureText: true,
                  cursorColor: Kcolor,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.password_rounded,
                      color: Kcolor,
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Kcolor)),
                    //enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Kcolor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Kcolor)),

                    labelText: 'Passwort',
                    labelStyle: TextStyle(
                      color: Kcolor,
                    ),
                    hintText: 'gib dein Passwort ein',
                  ),
                  validator: (value) =>
                      state.validPassword ? null : 'Passwort is required',
                  onChanged: (value) => context
                      .read<LoginBloc>()
                      .add(PasswordChanged(password: value))),
            ));
      },
    );
  }

  Widget _usernameField() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: Card(
            elevation: 5,
            child: TextFormField(
              cursorColor: Kcolor,
              decoration: const InputDecoration(
                  suffixIcon: Icon(
                    Icons.person,
                    color: Kcolor,
                  ),
                  border:
                      OutlineInputBorder(borderSide: BorderSide(color: Kcolor)),
                  //enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Kcolor)),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: Kcolor)),
                  labelText: 'Nutzername',
                  labelStyle: TextStyle(
                    color: Kcolor,
                  ),
                  hintText: 'gib deinen Benutzernamen ein'),
              validator: (value) =>
                  state.validUsername ? null : 'Nutzername is required',
              onChanged: (value) => context.read<LoginBloc>().add(
                    UsernameChanged(username: value),
                  ),
            ),
          ),
        );
      },
    );
  }
}
