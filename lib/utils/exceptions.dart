class UnauthorizedException implements Exception {
  @override
  String toString() {
    return 'invalid username/password';
  }
}
