abstract class ApiFormEvent {}

class ApiUrlChanged extends ApiFormEvent {
  final String? apiUrl;

  ApiUrlChanged({this.apiUrl});
}

class FormInit extends ApiFormEvent {}

class FormSubmitted extends ApiFormEvent {}

