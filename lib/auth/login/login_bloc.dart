import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';
import 'package:jallaliefern_taking_orders_app/auth/login/login_events.dart';
import 'package:jallaliefern_taking_orders_app/auth/login/login_state.dart';
import 'package:jallaliefern_taking_orders_app/services/login_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/exceptions.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // username updated
    if (event is UsernameChanged) {
      yield state.copyWith(username: event.username);
    }

    // password updated
    else if (event is PasswordChanged) {
      yield state.copyWith(password: event.password);
    }

    // Form Submitted
    else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        await locator<LoginService>()
            .getToken(username: state.username, password: state.password);
        yield state.copyWith(formStatus: SubmissionSuccess());
      } on Exception catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    } else if (event is LoginInit) {
      yield state.copyWith(formStatus: InitialFormStatus());
    }
  }
}
