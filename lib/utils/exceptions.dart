class MyException implements Exception {}
class UnauthorizedException implements MyException {
  @override
  String toString() {
    return 'invalid username/password';
  }
}
