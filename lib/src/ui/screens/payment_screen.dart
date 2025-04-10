import 'package:davlat/src/data/payment.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double totalAmount;
  const PaymentScreen({super.key, required this.totalAmount});

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Здесь можно добавить логику обработки платежа.
    _showDialog(context, 'Оплата', 'Платеж успешно обработан!');
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Способы оплаты",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildPaymentOptionCard(
              context,
              icon: Icons.credit_card,
              title: 'Банковская карта',
              description: 'Оплата картами российских банков',
              onTap: () {
                _processPayment(context);
              },
            ),
            const SizedBox(height: 15),
            _buildPaymentOptionCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Другие способы',
              description: 'Электронные кошельки, криптовалюта и т.д.',
              onTap: () {
                _showDialog(context, "Информация",
                    "Другие способы оплаты пока недоступны.");
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
