import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future write(String key, String value) async {
    var writeData = await _storage.write(key: key, value: value);
    return writeData;
  }

  Future read(String key) async {
    var readData = await _storage.read(key: key);
    return readData;
  }

  Future<bool> haskey(String key) async {
    var readData = await _storage.containsKey(key: key);
    return readData;
  }

  Future deleteAll() async {
    await _storage.deleteAll();
  }

  get apiUrl async => await read('api_url');
}
