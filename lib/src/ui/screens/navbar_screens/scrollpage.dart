import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:davlat/src/data/db/database.dart';
import 'package:davlat/src/exports.dart'; // должен экспортировать CardScreen

class ScrollPage extends StatefulWidget {
  const ScrollPage({Key? key}) : super(key: key);

  @override
  State<ScrollPage> createState() => _ScrollPageState();
}

class _ScrollPageState extends State<ScrollPage> {
  List<Map<String, String>> scrollData = [];
  final Set<String> likedImages = {};
  final DatabaseService _databaseService = DatabaseService();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadScrollData().then((_) => _loadLikedFromDb());
  }

  Future<void> _loadScrollData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/scroll_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        scrollData = jsonList.map<Map<String, String>>((item) {
          final map = <String, String>{
            'image': item['image'] as String,
            'name': item['name'] as String,
            'price': item['price'].toString(),
          };
          if (item.containsKey('discount')) {
            map['discount'] = item['discount'].toString();
          }
          return map;
        }).toList();
        scrollData.shuffle();
      });
      if (scrollData.isNotEmpty) {
        _pageController.dispose();
        _pageController = PageController(initialPage: scrollData.length * 1000);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки JSON: $e');
    }
  }

  Future<void> _toggleLike(String imagePath, String shoeName, String priceStr,
      [String? discount]) async {
    if (likedImages.contains(imagePath)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Внимание'),
          content: const Text('Товар уже в избранном'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ОК'),
            ),
          ],
        ),
      );
      return;
    }

    final cleanPriceStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final price = double.tryParse(cleanPriceStr) ?? 0.0;

    final Map<String, dynamic> product = {
      'image': imagePath,
      'name': shoeName,
      'price': price,
      if (discount != null) 'discount': discount,
    };

    await _databaseService.addFavoriteLocal(product);

    setState(() {
      likedImages.add(imagePath);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар добавлен в избранное')),
    );
  }

  Future<void> _loadLikedFromDb() async {
    final favs = await _databaseService.getFavoritesLocal();
    setState(() {
      likedImages
        ..clear()
        ..addAll(favs.map((e) => e['imagePath'] as String));
    });
  }

  // Future<void> _toggleLike(String imagePath, String shoeName, String priceStr,
  //     [String? discount]) async {
  //   if (likedImages.contains(imagePath)) {
  //     showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         title: const Text('Внимание'),
  //         content: const Text('Товар уже в избранном'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('ОК'),
  //           ),
  //         ],
  //       ),
  //     );
  //     return;
  //   }

  //   final cleanPriceStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
  //   final price = double.tryParse(cleanPriceStr) ?? 0.0;

  //   final Map<String, dynamic> product = {
  //     'image': imagePath,
  //     'name': shoeName,
  //     'price': price,
  //     if (discount != null) 'discount': discount,
  //   };

  //   await _databaseService.addFavoriteFull(product);

  //   setState(() {
  //     likedImages.add(imagePath);
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Товар добавлен в избранное')),
  //   );
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (scrollData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final currentIndex = index % scrollData.length;
          final item = scrollData[currentIndex];
          final imagePath = item['image']!;
          final shoeName = item['name']!;
          final priceStr = item['price']!;
          final cleanPrice = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
          final priceValue = double.tryParse(cleanPrice) ?? 0.0;
          final displayPrice = priceValue.toStringAsFixed(0);
          final isLiked = likedImages.contains(imagePath);
          final discount = item['discount'];

          final product = <String, dynamic>{
            'id': shoeName,
            'name': shoeName,
            'price': priceValue,
            'image': imagePath,
            if (discount != null) 'discount': discount,
          };

          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardScreen(product: product),
                    ),
                  );
                },
                child: Center(
                  child: Image.asset(
                    imagePath,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      shoeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 6,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$displayPrice ₽',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 40,
                        color: isLiked ? Colors.red : Colors.black,
                      ),
                      onPressed: () => _toggleLike(
                        imagePath,
                        shoeName,
                        priceStr,
                        discount,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.unfold_more_sharp,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardScreen(product: product),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
