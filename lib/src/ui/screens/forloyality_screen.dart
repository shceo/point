import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForloyalityScreen extends StatelessWidget {
  final int loyalty;

  const ForloyalityScreen({
    Key? key,
    required this.loyalty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Программа лояльности'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Синий контейнер почти на весь экран
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              width: mq.width,
              height: mq.height * 0.23,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Имя и фамилия пользователя
                  SizedBox(height: 10,),
                  Center(
                    child: Text(
                      user?.displayName ?? 'Гость',
                      style: const TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Карточка с логотипом и балансом
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/nike.png',
                        width: 80,
                        height: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Ваш баланс:\n$loyalty бонусов',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('loyaltyHistory')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'История пустая',
                    style: TextStyle(fontSize: 25),
                  ));
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: snap.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ts = data['timestamp'] as Timestamp?;
                    final time = ts?.toDate().toLocal().toString() ?? '';

                    final pts = data['points'] as int;
                    final action = data['action'] as String? ?? '';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 0),
                      leading: Icon(
                        pts > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: pts > 0 ? Colors.green : Colors.red,
                      ),
                      title: Text('$action: ${pts > 0 ? '+' : ''}$pts бонусов'),
                      subtitle: Text(time),
                    );
                  }).toList(),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
