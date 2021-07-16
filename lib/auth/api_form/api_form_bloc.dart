import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_events.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jallaliefern_taking_orders_app/auth/api_form/api_form_repository.dart';
import '../form_submission_status.dart';
import 'api_form_events.dart';
import 'api_form_state.dart';

class ApiFormBloc extends Bloc<ApiFormEvent, ApiFormState> {
  final ApiFormRepository apiFormRepo;
  ApiFormBloc({required this.apiFormRepo}) : super(ApiFormState());
  @override
  Stream<ApiFormState> mapEventToState(ApiFormEvent event) async* {
    // ApiUrl updated
    if (event is ApiUrlChanged) {
      yield state.copyWith(apiUrl: event.apiUrl);
    }
    // form submitted
    else if (event is FormSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        await apiFormRepo.save(apiUrl: state.apiUrl);
        yield state.copyWith(formStatus: SubmissionSuccess());
      } on Exception catch (e) {
        yield state.copyWith(formStatus: SubmissionFailed(e));
      }
    } else if (event is FormInit) {
      yield state.copyWith(formStatus: InitialFormStatus());
    }
  }
}
