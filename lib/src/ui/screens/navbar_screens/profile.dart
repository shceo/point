import 'package:davlat/src/exports.dart';
import 'package:davlat/src/ui/screens/history.dart';
import 'package:davlat/src/ui/screens/profile_editscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Предполагается, что LoginPage и LikePage существуют и импортированы
// import 'package:davlat/src/ui/screens/login_page.dart';
// import 'package:davlat/src/ui/screens/like_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Если пользователь не залогинен и диалог ещё не показывался, показываем его.
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Внимание'),
              content: const Text(
                  'Для доступа к профилю необходимо войти в аккаунт или зарегистрироваться.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Войти'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Напомни позже'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<void> _confirmSignOut() async {
    bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: const Text('Вы действительно хотите выйти из аккаунта?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
      setState(() {}); // Обновляем экран после выхода
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final List<Map<String, dynamic>> favoriteProducts = [];
    List<Map<String, dynamic>> myOrders =
        []; // или заполняется реальными данными

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Профиль',
          style: GoogleFonts.oswald(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF9F9F9),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Верхняя панель с данными пользователя
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 33, 17, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'assets/images/profile.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Войдите в аккаунт',
                            style: GoogleFonts.oswald(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Почта не указана',
                            style: GoogleFonts.oswald(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditscreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Верхняя секция кнопок профиля (отдельный контейнер)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 1. Об аккаунте
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/Profile.png',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Об аккаунте',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
                      subtitle: Text(
                        'Изменить данные об аккаунте',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ),
                      trailing: Image.asset(
                        'assets/icons/arrow.png',
                        width: 16,
                        height: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileEditscreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.grey, height: 1),
                    // 2. Избранное
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/love.png',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Избранное',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
                      subtitle: Text(
                        'Список с понравшимися вам товарами',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ),
                      trailing: Image.asset(
                        'assets/icons/arrow.png',
                        width: 16,
                        height: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LikePage(
                              likedImages: favoriteProducts
                                  .map<String>((p) => p['image'] as String)
                                  .toList(),
                              likedNames: favoriteProducts
                                  .map<String>((p) => p['name'] as String)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.grey, height: 1),
                    // 3. История заказов
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/order.png',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'История заказов',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
                      subtitle: Text(
                        'Все ваши покупки в одном месте',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ),
                      trailing: Image.asset(
                        'assets/icons/arrow.png',
                        width: 16,
                        height: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderHis(orders: myOrders),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Нижняя секция "Помощь" (отдельный контейнер)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Помощь',
                  style: GoogleFonts.oswald(
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Обратная связь
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/notif.png',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Обратная связь',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
                      subtitle: Text(
                        'Можете задать любой интересующий вопрос',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ),
                      trailing: Image.asset(
                        'assets/icons/arrow.png',
                        width: 16,
                        height: 16,
                      ),
                      onTap: () {
                        // Навигация к странице обратной связи
                      },
                    ),
                    const Divider(color: Colors.grey, height: 1),
                    // Выйти
                    ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFF0601B4),
                        size: 24,
                      ),
                      title: Text(
                        'Выйти',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
                      subtitle: Text(
                        'Войти в другой аккаунт или создать новый',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ),
                      trailing: Image.asset(
                        'assets/icons/arrow.png',
                        width: 16,
                        height: 16,
                      ),
                      onTap: () async {
                        await _confirmSignOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Помощь & Поддержка')));
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('О приложении')));
  }
}
