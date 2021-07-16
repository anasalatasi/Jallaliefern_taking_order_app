class AuthRepository {
  Future<String> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 3));
    return 'abc';
  }
}
