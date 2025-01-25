import 'package:get_it/get_it.dart';

import '../services/call_sms.dart';

GetIt locator =
    GetIt.instance; // Updated to use the named constructor 'instance'

void setupLocator() {
  locator.registerSingleton(CallsAndMessagesService());
}
