import 'package:davlat/src/exports.dart';
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
  final List<String> _tabs = ['Повседневная', 'Спортивная', 'Распродажа'];
  final List<List<Map<String, dynamic>>> _products = [
    List.generate(
      20,
      (index) => {
        'id': 'casual${index + 1}',
        'name': 'AirJordan ${index + 1}',
        'price': (index + 1) * 10,
        'image': 'assets/scroll/${index + 1}.png',
      },
    ),
    List.generate(
      20,
      (index) => {
        'id': 'run${index + 1}',
        'name': 'Бег ${index + 1}',
        'price': (index + 1) * 15,
        'image': 'assets/scroll/${index + 9}.png',
      },
    ),
    List.generate(
      20,
      (index) => {
        'id': 'tennis${index + 1}',
        'name': 'Теннис ${index + 1}',
        'price': (index + 1) * 20,
        'image': 'assets/scroll/${index + 17}.png',
      },
    ),
  ];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Загружает список избранного из БД и обновляет favoriteProducts,
  /// сопоставляя сохранённые image со списком продуктов.
  Future<void> _loadFavorites() async {
    final List<String> favImages = await _databaseService.getFavorites();
    List<Map<String, dynamic>> favProducts = [];
    for (var tab in _products) {
      for (var product in tab) {
        if (favImages.contains(product['image'])) {
          favProducts.add(product);
        }
      }
    }
    setState(() {
      favoriteProducts
        ..clear()
        ..addAll(favProducts);
    });
  }

  Future<void> _addToFavorites(Map<String, dynamic> product) async {
    // Проверяем по image, а не по ссылке на объект.
    if (favoriteProducts.any((p) => p['image'] == product['image'])) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Внимание'),
            content: Text('${product['name']} уже в избранном'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОК'),
              ),
            ],
          );
        },
      );
      return;
    }
    await _databaseService.addFavorite(product['image']);
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

  Future<void> _addToBag(Map<String, dynamic> product) async {
    final newProduct = Map<String, dynamic>.from(product);
    newProduct['counter'] = 1;
    await _databaseService.addToBasket(
      productId: product['id'],
      name: product['name'],
      price: (product['price'] as num).toDouble(),
      size: "9.5",
      color: "красный",
      imagePath: product['image'],
    );

    setState(() {
      bagItems.add(newProduct);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} добавлен в корзину'),
        duration: const Duration(seconds: 2),
      ),
    );
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
        // Удаляем из списка товары, которых больше нет в базе избранного.
        favoriteProducts
            .removeWhere((product) => !result.contains(product['image']));
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок коллекции
            Text(
              'Новая Коллекция',
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
            // Новый баннер: синий адаптивный контейнер вместо картинки
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *
                      0.2, // 20% от высоты экрана
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      // Верхний текст
                      const Positioned(
                        top: 16,
                        left: 16,
                        child: Text(
                          '20% скидки',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Мини-текст ниже
                      const Positioned(
                        top: 48,
                        left: 16,
                        child: Text(
                          'на новую\n коллекцию',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Кнопка в нижней части
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset('assets/images/shoe.png',)),
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
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
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
                  _products[_selectedTabIndex].length,
                  (index) => SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child:
                        _buildProductCard(_products[_selectedTabIndex][index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Проверяем, содержится ли product по image в favoriteProducts.
    bool isFavorite =
        favoriteProducts.any((p) => p['image'] == product['image']);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Stack(
        children: [
          // Фон карточки обёрнут в InkWell для навигации
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardScreen(product: product),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Image.asset(
                    product['image'],
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    product['name'],
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
                    '\$${product['price']}',
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
          // Кнопка "лайк"
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                _addToFavorites(product);
              },
            ),
          ),
          // Кнопка "корзина"
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
              onPressed: () {
                _addToBag(product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
