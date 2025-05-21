import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    _ordersFuture = _loadAllOrders();
  }

  /// Загружает локальные + удалённые (Firestore) заказы
  Future<List<Map<String, dynamic>>> _loadAllOrders() async {
    // 1) локальные
    final local = await DatabaseService().getOrders();

    // 2) из Firestore, если есть залогиненный пользователь
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return local;
    }
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .get();

    final remote = snap.docs.map((doc) {
      final data = doc.data();
      return {
        'imagePath': data['imagePath'] as String? ?? '',
        'name': data['name'] as String? ?? '',
        'price': (data['price'] as num?)?.toDouble() ?? 0.0,
        'counter': data['counter'] as int? ?? 1,
        'size': data['size'] as String? ?? '',
        'color': data['color'] as String? ?? '',
      };
    }).toList();

    // объединим: Firestore + локальные (локальные могут быть устаревшими, но сохраняем оба)
    return [...remote, ...local];
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
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data ?? [];
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
              final image = order['imagePath'] as String;
              final name = order['name'] as String;
              final price = order['price'] as double;
              final counter = order['counter'] as int;
              final size = order['size'] as String;
              final color = order['color'] as String;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (image.isNotEmpty)
                        Image.asset(image,
                            width: 80, height: 80, fit: BoxFit.cover),
                      if (image.isEmpty) const SizedBox(width: 80, height: 80),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Цена: ${(price * counter).toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Параметры: Размер $size, Цвет $color',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
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
