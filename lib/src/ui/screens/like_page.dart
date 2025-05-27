import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:davlat/src/data/db/database.dart';
import 'package:davlat/src/exports.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> likedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _databaseService.getFavoritesLocal();
    setState(() {
      likedProducts = favs;
    });
  }

  Future<void> _removeFromFavorites(String imagePath) async {
    await _databaseService.removeFavoriteLocal(imagePath);
    setState(() {
      likedProducts = [];
    });
  }

  Future<void> _clearFavorites() async {
    for (var p in likedProducts) {
      await _databaseService.removeFavoriteLocal(p['imagePath']);
    }
    setState(() {
      likedProducts = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Возвращаем только список imagePath при выходе назад
        final updatedImagePaths = likedProducts
            .map((product) => product['imagePath'] as String)
            .toList();
        Navigator.pop(context, updatedImagePaths);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Избранное', style: GoogleFonts.oswald()),
          centerTitle: true,
          actions: [
            if (likedProducts.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Очистить избранное',
                onPressed: _clearFavorites,
              ),
          ],
        ),
        body: likedProducts.isEmpty
            ? Center(
                child: Text(
                  'Нет избранных кроссовок',
                  style: GoogleFonts.oswald(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: likedProducts.length,
                itemBuilder: (context, index) {
                  final product = likedProducts[index];
                  final imagePath = product['imagePath'];
                  final name = product['name'] ?? 'Товар';
                  final price = product['price'] ?? 0.0;

                  return Dismissible(
                    key: ValueKey(imagePath),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeFromFavorites(imagePath),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 30),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Image.asset(
                          imagePath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          name,
                          style: GoogleFonts.oswald(
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Text(
                          '$price ₽',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          final fullProduct = {
                            'id': name,
                            'name': name,
                            'price': price,
                            'image': imagePath,
                            if (product['discount'] != null)
                              'discount': product['discount'],
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CardScreen(product: fullProduct),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
