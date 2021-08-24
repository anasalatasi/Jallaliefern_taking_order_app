import 'package:get_it/get_it.dart';
import 'package:jallaliefern_taking_orders_app/models/restaurant.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/services/login_service.dart';
import 'package:jallaliefern_taking_orders_app/services/printer_service.dart';
import 'package:jallaliefern_taking_orders_app/services/secure_storage_service.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerSingleton(SecureStorageService());
  locator.registerSingleton(LoginService());
  locator.registerSingleton(ApiService());
  locator.registerSingleton(Restaurant.empty());
  locator.registerSingleton(PrinterService());
}
