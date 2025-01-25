import 'package:url_launcher/url_launcher.dart';

class CallsAndMessagesService {
  void call(String number) => launchUrl("tel:$number" as Uri);
  void sendSms(String number) => launchUrl("sms:$number" as Uri);
  void sendEmail(String email) => launchUrl("mailto:$email" as Uri);
}
