import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp for the given [phoneNumber] with an optional [message].
///
/// The phone number must be in international format **without** the leading `+`.
/// Example: `9779801234567` for a Nepal number.
Future<void> openWhatsApp(String phoneNumber, {String message = ''}) async {
  final url = Uri.parse(
    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Could not launch WhatsApp');
  }
}
