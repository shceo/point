// lib/src/ui/screens/payment_screen.dart

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

/// Вынесенный репозиторий для работы с API ЮKassa
class CassaRepo {
  // TODO: заполните значениями вашего магазина
  static const String shopId = '1054000';
  static const String secretKey = 'test_wdpD9DOXt65p1Tt02FK9LjGLyjbxz-19mYilgdc8Sj4';

  /// Создаёт платёж на сумму [amount] и сразу открывает страницу подтверждения
  static Future<void> createPayment(double amount) async {
    const url = 'https://api.yookassa.ru/v3/payments';
    final idempotenceKey = const Uuid().v4();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$shopId:$secretKey')),
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
          // deep-link вашего приложения
          'return_url': 'myapp://payment-callback',
        },
        'capture': true,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final confirmationUrl = data['confirmation']['confirmation_url'];
      final paymentId = data['id'];

      log('Платёж создан, id=$paymentId');

      // Открываем страницу подтверждения в браузере/приложении
      final uri = Uri.parse(confirmationUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log('Не удалось открыть $confirmationUrl');
      }

      // Здесь вы можете, при необходимости, запустить опрос статуса:
      // await checkPaymentStatus(paymentId);
    } else {
      log('Ошибка создания платежа: ${response.statusCode}');
      log('Тело ответа: ${response.body}');
      throw Exception('Не удалось создать платёж');
    }
  }

  /// Опционально: проверка статуса по [paymentId]
  static Future<String> checkPaymentStatus(String paymentId) async {
    final url = 'https://api.yookassa.ru/v3/payments/$paymentId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$shopId:$secretKey')),
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data['status'] as String;
      log('Статус платежа $paymentId: $status');
      return status;
    } else {
      log('Ошибка статуса: ${response.statusCode}');
      throw Exception('Не удалось получить статус платежа');
    }
  }
}

/// Экран выбора способа оплаты и инициации платежа
class PaymentScreen extends StatelessWidget {
  final double totalAmount;

  const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  void _showMessage(BuildContext ctx, String title, String msg) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите способ оплаты'),
        centerTitle: true,
        backgroundColor: Colors.white70,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Сумма к оплате: ${totalAmount.toStringAsFixed(2)} ₽',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Банковская карта:
            _buildPaymentOptionCard(
              context,
              icon: Icons.credit_card,
              title: 'Банковская карта',
              description: 'Оплата картами российских банков',
              onTap: () async {
                try {
                  await CassaRepo.createPayment(totalAmount);
                } catch (e) {
                  _showMessage(context, 'Ошибка', e.toString());
                }
              },
            ),
            const SizedBox(height: 15),
            // Другие способы:
            _buildPaymentOptionCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Другие способы',
              description: 'Электронные кошельки, криптовалюта и т.д.',
              onTap: () {
                _showMessage(context, 'Информация',
                    'Другие способы оплат пока недоступны.');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Icon(icon, size: 40, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
