import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';

class LoginState {
  final String username;
  bool get validUsername => username.isNotEmpty;
  final String password;
  bool get validPassword => password.isNotEmpty;
  final FormSubmissionStatus formStatus;
  LoginState(
      {this.username = '',
      this.password = '',
      this.formStatus = const InitialFormStatus()});

  LoginState copyWith(
      {String? username, String? password, FormSubmissionStatus? formStatus}) {
    return LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
        formStatus: formStatus ?? this.formStatus);
  }
}
