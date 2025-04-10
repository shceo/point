import 'package:davlat/src/exports.dart';

class AfterSplashscreen extends StatefulWidget {
  const AfterSplashscreen({super.key});

  @override
  State<AfterSplashscreen> createState() => _AfterSplashscreenState();
}

class _AfterSplashscreenState extends State<AfterSplashscreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Homepage(),
    const ScrollPage(),
    const BagScreen(),
    // LikePage(
    //   likedImages: const [],
    //   likedNames: [],
    // ),
    const Profile(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
