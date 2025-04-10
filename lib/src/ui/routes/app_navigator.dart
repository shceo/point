import 'package:davlat/src/exports.dart';
import 'package:go_router/go_router.dart';


class AppNavigator {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.afterSplashscreen,
        builder: (context, state) => const AfterSplashscreen(),
      ),
     
    ],
  );
}
