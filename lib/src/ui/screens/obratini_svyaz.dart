import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _defaultEmail = 'ozonkee@gmail.com';

  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user!.email ?? '';
    } else {
      _emailController.text = _defaultEmail;
    }
    setState(() {});
  }

  Future<void> _sendFeedback() async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите сообщение перед отправкой')),
      );
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: _defaultEmail,
      queryParameters: {
        'subject': 'Feedback from $email',
        'body': message,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть почтовое приложение')),
      );
    }
  }

  Future<void> _openTelegram() async {
    final uri = Uri.parse('https://t.me/syodamn');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'loyalty': FieldValue.increment(5)}, SetOptions(merge: true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть Telegram')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обратная связь')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ваш email:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Сообщение:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите ваше сообщение...',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _sendFeedback,
                child: const Text('Отправить'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _openTelegram,
                child: const Text('Остались вопросы? Telegram'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
