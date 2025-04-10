import 'dart:async';
import 'package:davlat/src/exports.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      DatabaseService().database;
      final initializationProgress =
          ValueNotifier<({int progress, String message})>(
        (progress: 0, message: 'Начало инициализации'),
      );

      runApp(BlocProvider(
        create: (context) => AuthenticationBloc(),
        child: SplashScreen(progress: initializationProgress),
      ));

      Timer.periodic(
        const Duration(milliseconds: 30),
        (timer) {
          final currentProgress = initializationProgress.value.progress + 1;
          if (currentProgress >= 100) {
            initializationProgress.value =
                (progress: 100, message: 'Подождите...');
            timer.cancel();
            Future.delayed(
              const Duration(seconds: 1),
              () {
                runApp(BlocProvider(
                  create: (context) => AuthenticationBloc(),
                  child: const App(),
                ));
              },
            );
          } else {
            initializationProgress.value = (
              progress: currentProgress,
              message: 'Загрузка... $currentProgress%'
            );
          }
        },
      );
    },
    (error, stackTrace) {
      debugPrint('Error: $error');
    },
  );
}
