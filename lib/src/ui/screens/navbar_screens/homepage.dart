import 'dart:convert';
import 'dart:math';

import 'package:davlat/src/exports.dart'; // Предполагает, что туда входит CardScreen
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseService _databaseService = DatabaseService();

  final List<Map<String, dynamic>> bagItems = [];
  final List<Map<String, dynamic>> favoriteProducts = [];
  List<Map<String, dynamic>> _categories = [];
  int _selectedTabIndex = 0;

  List<String> get _tabs =>
      _categories.map((c) => c['name'] as String).toList();

  @override
  void initState() {
    super.initState();
    _loadProductsFromJson();
    _loadFavorites();
  }

  /// Загрузка категорий и продуктов из JSON-файла
  Future<void> _loadProductsFromJson() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/products.json');
      final Map<String, dynamic> decoded = json.decode(jsonString);
      final loaded = (decoded['categories'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // Генерируем уникальный id для каждого продукта по его имени
      for (var category in loaded) {
        final products = category['products'] as List<dynamic>;
        for (var prod in products) {
          final p = prod as Map<String, dynamic>;
          p['id'] = p['name'] as String;
        }
      }

      setState(() {
        _categories = loaded;
        _assignRandomDiscounts();
      });
    } catch (e) {
      debugPrint('Ошибка загрузки JSON: $e');
    }
  }

  /// Загружает список избранного из БД и обновляет favoriteProducts
  Future<void> _loadFavorites() async {
    final List<String> favImages = await _databaseService.getFavorites();
    List<Map<String, dynamic>> favProducts = [];
    for (var category in _categories) {
      final products = category['products'] as List<dynamic>;
      for (var prod in products) {
        final p = prod as Map<String, dynamic>;
        if (favImages.contains(p['image'] as String)) {
          favProducts.add(p);
        }
      }
    }
    setState(() {
      favoriteProducts
        ..clear()
        ..addAll(favProducts);
    });
  }

  void _assignRandomDiscounts() {
    final rand = Random();
    for (var category in _categories) {
      final products = category['products'] as List<dynamic>;
      for (var prod in products) {
        final p = prod as Map<String, dynamic>;
        if (rand.nextBool()) {
          p['discount'] = 20;
        }
      }
    }
  }

  Future<void> _addToFavorites(Map<String, dynamic> product) async {
    if (favoriteProducts.any((p) => p['image'] == product['image'])) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Внимание'),
          content: Text('${product['name']} уже в избранном'),
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
    await _databaseService.addFavorite(product['image'] as String);
    setState(() {
      favoriteProducts.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} добавлен в избранное'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Теперь вместо прямого добавления мы открываем CardScreen,
  /// где пользователь выберет размер и цвет.
  Future<void> _addToBag(Map<String, dynamic> product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardScreen(product: product),
      ),
    );
    // После возврата из CardScreen можно обновить список корзины,
    // если нужно тут, например:
    // _loadBagItems();
  }

  Future<void> _navigateToLikePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikePage(
          likedImages: favoriteProducts
              .map<String>((p) => p['image'] as String)
              .toList(),
          likedNames:
              favoriteProducts.map<String>((p) => p['name'] as String).toList(),
        ),
      ),
    );
    if (result != null && result is List<String>) {
      setState(() {
        favoriteProducts.removeWhere(
            (product) => !result.contains(product['image'] as String));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/icons/nike.png',
          height: 40,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset('assets/icons/like.png', color: Colors.black),
            onPressed: _navigateToLikePage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок коллекции
            Text(
              'Новая коллекция',
              style: GoogleFonts.oswald(
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Эксклюзивная подборка для нового сезона',
              style: GoogleFonts.oswald(
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Баннер
            Stack(
              children: [
                Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 16,
                        left: 16,
                        child: Text(
                          '20% скидка',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 48,
                        left: 16,
                        child: Text(
                          'на новую\nколлекцию',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset('assets/images/shoe.png'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Табы
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _tabs.length,
                (index) => Expanded(
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedTabIndex = index;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Text(
                        _tabs[index],
                        style: GoogleFonts.oswald(
                          textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedTabIndex == index
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Сетка продуктов
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                  (_categories.isNotEmpty
                      ? (_categories[_selectedTabIndex]['products']
                              as List<dynamic>)
                          .length
                      : 0),
                  (index) {
                    final product = (_categories[_selectedTabIndex]['products']
                        as List<dynamic>)[index] as Map<String, dynamic>;
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      child: _buildProductCard(product),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    bool isFavorite =
        favoriteProducts.any((p) => p['image'] == product['image']);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardScreen(product: product),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Image.asset(
                    product['image'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    product['name'] as String,
                    style: GoogleFonts.oswald(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${product['price']} ₽',
                    style: GoogleFonts.oswald(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => _addToFavorites(product),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
              onPressed: () => _addToBag(product),
            ),
          ),
        ],
      ),
    );
  }
}
