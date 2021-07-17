import 'package:get_it/get_it.dart';
import 'package:jallaliefern_taking_orders_app/services/login_service.dart';
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';
GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerSingleton(SecureStorageService());
  locator.registerSingleton(LoginService());
}