import '../form_submission_status.dart';
import 'package:validators/validators.dart';
class ApiFormState {
  final String apiUrl;
  bool get validApiUrl => isURL(apiUrl);
  final FormSubmissionStatus formStatus;
  ApiFormState({this.apiUrl = '', this.formStatus = const InitialFormStatus()});

  ApiFormState copyWith({String? apiUrl, FormSubmissionStatus? formStatus}) {
    return ApiFormState(
        apiUrl: apiUrl ?? this.apiUrl,
        formStatus: formStatus ?? this.formStatus);
  }
}
