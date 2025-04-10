import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _defaultEmail = 'ozonkee@gmail.com';

  Future<void> _sendFeedback() async {
    // Пример отправки сообщения на email через url scheme (будет открывать почтовый клиент)
    final emailUrl = Uri.parse(
        'mailto:$_defaultEmail?subject=Feedback&body=${_messageController.text}');
    // ignore: deprecated_member_use
    if (await canLaunch(emailUrl.toString())) {
      await launch(emailUrl.toString());
    } else {
      throw 'Could not send email';
    }
  }

  Future<void> _openTelegram() async {
    const telegramUrl = 'https://t.me/syodamn';
    if (await canLaunch(telegramUrl)) {
      await launch(telegramUrl);
    } else {
      throw 'Could not open Telegram';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обратная связь'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Введите ваш email:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Ваш email',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ваше сообщение:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Введите ваше сообщение...',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Отправить',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _openTelegram,
                  child: const Text(
                    'Остались вопросы? Задавайте тут!',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
