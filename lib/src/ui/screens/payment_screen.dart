// lib/src/ui/screens/payment_screen.dart

import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:davlat/src/data/db/database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Репозиторий для создания платежа на YooKassa
class CassaRepo {
  static const String shopId = '1053999';
  static const String secretKey =
      'test_iVXfpVrUuUMx8bZxlU78lHmTGIBc6FwITguV15PU6_w';

  /// Инициализируем платёж и возвращаем URL для WebView
  static Future<String> createPaymentUrl(double amount) async {
    const api = 'https://api.yookassa.ru/v3/payments';
    final idKey = const Uuid().v4();

    final resp = await http.post(
      Uri.parse(api),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$shopId:$secretKey')),
        'Content-Type': 'application/json',
        'Idempotence-Key': idKey,
      },
      body: jsonEncode({
        'amount': {
          'value': amount.toStringAsFixed(2),
          'currency': 'RUB',
        },
        'payment_method_data': {'type': 'bank_card'},
        'confirmation': {
          'type': 'redirect',
          // YooKassa вставит этот return_url в кнопку "вернуться назад"
          'return_url': 'myapp://payment-callback',
        },
        'capture': true,
      }),
    );

    if (resp.statusCode != 200) {
      log('YooKassa error: ${resp.statusCode}\n${resp.body}');
      throw Exception('Не удалось инициализировать платёж');
    }

    final data = jsonDecode(resp.body);
    return data['confirmation']['confirmation_url'] as String;
  }
}

/// Экран, внутри которого мы запустим WebView и дождёмся диплинка
class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  String? _url;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startPayment();
  }

  Future<void> _startPayment() async {
    try {
      final url = await CassaRepo.createPaymentUrl(widget.totalAmount);
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (req) {
              // ловим диплинк
              if (req.url.startsWith('myapp://payment-callback')) {
                _onPaymentSuccess();
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageStarted: (_) => setState(() => _loading = true),
            onPageFinished: (_) => setState(() => _loading = false),
          ),
        )
        ..loadRequest(Uri.parse(url));

      setState(() => _url = url);
    } catch (e) {
      _showError('Ошибка', e.toString());
    }
  }

  Future<void> _onPaymentSuccess() async {
    final db = DatabaseService();
    final basket = await db.getBasketItems();

    // 1) Сначала добавляем локально
    for (var item in basket) {
      await db.addOrder(item);
    }
    // 2) Затем отправляем каждый заказ в Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userOrders = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders');
      for (var item in basket) {
        await userOrders.add({
          'name': item['name'] as String,
          'price': item['price'] as num,
          'counter': item['counter'] as int,
          'size': item['size'] as String,
          'color': item['color'] as String,
          'imagePath': item['imagePath'] as String,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }

    // 3) Очищаем локальную корзину
    await db.clearBasket();

    // 4) Показываем диалог успеха
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Успех'),
        content: const Text('Оплата успешно завершена!',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                ..pop() // закрыть диалог
                ..pop(); // вернуться из PaymentScreen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg, textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_url == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Оплата')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
