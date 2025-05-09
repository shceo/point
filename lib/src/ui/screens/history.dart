import 'package:davlat/src/data/db/database.dart';
import 'package:flutter/material.dart';

class OrderHis extends StatefulWidget {
  const OrderHis({Key? key}) : super(key: key);

  @override
  State<OrderHis> createState() => _OrderHisState();
}

class _OrderHisState extends State<OrderHis> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    // При старте экрана сразу дёргаем базу
    _ordersFuture = DatabaseService().getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Заказы отсутствуют',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final image   = order['imagePath'] as String? ?? '';
              final name    = order['name']      as String? ?? 'Без имени';
              final price   = order['price']     as double? ?? 0.0;
              final counter = order['counter']   as int? ?? 1;
              final size    = order['size']      as String? ?? '';
              final color   = order['color']     as String? ?? '';
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Цена: ${(price * counter).toStringAsFixed(2)} \$',
                                style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text('Параметры: Размер $size, Цвет $color',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
