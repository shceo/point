import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';


class CassaRepo {
  static String shopId = "1053999";
  static String secretKey = "test_iVXfpVrUuUMx8bZxlU78lHmTGIBc6FwITguV15PU6_w";

  static Future<void> createPayment(double amount) async {
    const String url = 'https://api.yookassa.ru/v3/payments';
    final idempotenceKey = const Uuid().v4();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$shopId:$secretKey'))}',
        'Content-Type': 'application/json',
        'Idempotence-Key': idempotenceKey,
      },
      body: jsonEncode({
        'amount': {
          'value': amount.toStringAsFixed(2),
          'currency': 'RUB',
        },
        'payment_method_data': {'type': 'bank_card'},
        'confirmation': {
          'type': 'redirect',
          'return_url':
              'www.google.com',
        },
        'capture': true,
      }),
    );

    if (response.statusCode == 200) {
      log('Payment created: ${response.body}');
      final paymentData = jsonDecode(response.body);
      final confirmationUrl = paymentData['confirmation']['confirmation_url'];
      final paymentId = paymentData['id']; // Сохраняем идентификатор платежа
      // Открываем URL подтверждения
      final Uri uri = Uri.parse(confirmationUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log('Could not launch $confirmationUrl');
      }
      // Теперь вы можете проверить статус платежа с помощью paymentId
      await checkPaymentStatus(paymentId);
    } else {
      log('Error creating payment: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  }

  static Future<void> checkPaymentStatus(String paymentId) async {
    //     waiting_for_capture — платеж ожидает подтверждения.
    // succeeded — платеж успешно завершен.
    // canceled — платеж отменен.
    final String url = 'https://api.yookassa.ru/v3/payments/$paymentId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$shopId:$secretKey'))}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final paymentData = jsonDecode(response.body);
      final paymentStatus = paymentData['status'];
      log('Payment status: $paymentStatus');
      // Здесь вы можете добавить логику для обработки различных статусов
    } else {
      log('Error checking payment status: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  }
}
