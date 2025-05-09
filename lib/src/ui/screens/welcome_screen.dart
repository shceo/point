import 'package:davlat/src/exports.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: Image.asset('assets/icons/nike.png', width: 80, height: 80,),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Positioned(
          //   top: MediaQuery.of(context).size.height * 0/1,
          //   left: 0,
          //   right: 0,
          //   bottom: MediaQuery.of(context).size.height * 0.2,
          //   child: Opacity(
          //     opacity: 1,
          //     child: Image.asset(
          //       'assets/icons/jdi.png',
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/icons/jdi.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  painter: HighlightPainter(),
                  child: const AutoSizeText(
                    'Раскрой свой потенциал,\n подними игру',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ClashDisplayVariable',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 30.0, left: 20.0, right: 20.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  minimumSize: WidgetStateProperty.all<Size>(
                      const Size(double.infinity, 60)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const AfterSplashscreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );  
                },
                child: const Text('Начать', style: TextStyle(fontSize: 18.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'свой',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'ClashDisplayVariable',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2);

    final rect = Rect.fromLTWH(
      offset.dx * 1.36,
      offset.dy - 70,
      textPainter.width + 65,
      textPainter.height + 28,
    );

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
