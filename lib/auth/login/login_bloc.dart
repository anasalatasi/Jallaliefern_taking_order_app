import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/form_submission_status.dart';
import 'package:jallaliefern_taking_orders_app/auth/login/login_events.dart';
import 'package:jallaliefern_taking_orders_app/auth/login/login_state.dart';
import 'auth_repository.dart';
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;

  LoginBloc({required this.authRepo}) : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    // username updated
    if (event is UsernameChanged) {
      yield state.copyWith(username: event.username);
    }

    // password updated
    else if (event is PasswordChanged){
      yield state.copyWith(password: event.password);
    }

    // Form Submitted
    else if (event is LoginSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        await authRepo.login(username: state.username,password: state.password);
        yield state.copyWith(formStatus: SubmissionSuccess());
      } on Exception catch(e) {
      yield state.copyWith(formStatus: SubmissionFailed(e));
    }
  }
}
}