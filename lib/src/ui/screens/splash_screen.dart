import 'package:davlat/src/exports.dart';

class SplashScreen extends StatelessWidget {
  final ValueNotifier<({int progress, String message})> progress;

  const SplashScreen({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splash.jpg'), 
                  fit: BoxFit.cover, 
                ),
              ),
            ),
            Center(
              child: ValueListenableBuilder(
                valueListenable: progress,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      const Spacer(), 
                      CircularProgressIndicator(
                        value: value.progress / 100,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${value.message} (${value.progress}%)',
                        style: const TextStyle(
                          color: Colors.black, // Цвет текста
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40), // Отступ от нижнего края
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
