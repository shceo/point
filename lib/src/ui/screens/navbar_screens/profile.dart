import 'package:davlat/src/exports.dart';
import 'package:davlat/src/ui/screens/forloyality_screen.dart';
import 'package:davlat/src/ui/screens/history.dart';
import 'package:davlat/src/ui/screens/obratini_svyaz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _dialogShown = false;
  int _loyalty = 0;

  @override
  void initState() {
    super.initState();
    _loadLoyalty();
  }

  Future<void> _loadLoyalty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    const int maxRetries = 3;
    int attempt = 0;
    while (true) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!mounted) return;
        setState(() {
          _loyalty = (doc.data()?['loyalty'] as int?) ?? 0;
        });
        return;
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable' && attempt < maxRetries) {
          attempt++;
          await Future.delayed(Duration(seconds: 1 << attempt));
          continue;
        }
        // Если не mounted или исчерпали попытки
        if (!mounted) return;
        showToast('Не удалось загрузить бонусы. Проверьте соединение.');
        setState(() => _loyalty = 0);
        return;
      }
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
      if (!mounted) return;
      setState(() {
        _dialogShown = false; // Сбросим флаг, чтобы снова показать диалог
      });
    }
  }

  Future<void> _addLoyaltyPoints(int points) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // 1) Увеличиваем общий баланс
    await userRef.set(
      {'loyalty': FieldValue.increment(points)},
      SetOptions(merge: true),
    );

    // 2) Добавляем запись в историю
    await userRef.collection('loyaltyHistory').add({
      'points': points,
      'action':
          'Начисление за действие', // например, 'Оплата', 'Вход', 'Регистрация' и т.д.
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    setState(() {
      _loyalty += points;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final List<Map<String, dynamic>> favoriteProducts = [];
    List<Map<String, dynamic>> myOrders =
        []; // или заполняется реальными данными
    if (FirebaseAuth.instance.currentUser == null && !_dialogShown) {
      _dialogShown = true;
      Future.microtask(() {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Войдите в аккаунт'),
              content: const Text(
                  'Для доступа к профилю необходимо авторизоваться'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text('Войти'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Позже'),
                ),
              ],
            );
          },
        );
      });
    }
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditscreen(),
                    ),
                  );
                },
                child: Stack(
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
                            const SizedBox(height: 4),
                            Text(
                              'Ваши бонусы: $_loyalty',
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
                          icon: Image.asset('assets/icons/in.png'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
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
                        'Программа лояльности',
                        style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
                      subtitle: Text(
                        'Ваши бонусы за ваши покупки',
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
                              builder: (context) =>
                                  ForloyalityScreen(loyalty: _loyalty),
                            ));
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
                            builder: (context) => const OrderHis(),
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
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/notif.png',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Поддержка',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedbackPage(),
                          ),
                        );
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
