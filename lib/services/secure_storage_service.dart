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
  get receiptCopies async {
    if (await haskey('receipt_copies')) {
      var tmp = await read('receipt_copies');
      if (tmp == "") return 0;
      return int.parse(tmp);
    }
    write('receipt_copies', '1');
    return 1;
  }

  get printerIp async {
    String tmp = await read('printer_ip');
    return tmp;
  }

  get accessToken async => await read('access_token');
}
