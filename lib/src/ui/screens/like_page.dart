import 'package:davlat/src/exports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class LikePage extends StatefulWidget {
  final List<String> likedImages;
  final List<String> likedNames;

  const LikePage({
    super.key,
    required this.likedImages,
    required this.likedNames,
  });

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  final DatabaseService _databaseService = DatabaseService();
  List<String> likedImages = [];
  List<String> likedNames = [];

  @override
  void initState() {
    super.initState();
    _loadLikedItems();
  }

  Future<void> _loadLikedItems() async {
    final images = await _databaseService.getFavorites();
    setState(() {
      likedImages = images;
      likedNames = images.map((image) {
        final match = RegExp(r'(\d+)\.png').firstMatch(image);
        if (match != null) {
          return 'Кроссовка ${match.group(1)}';
        }
        return 'Кроссовка';
      }).toList();
    });
  }

  Future<void> _removeFromFavorites(String imagePath) async {
    await _databaseService.removeFavorite(imagePath);
    setState(() {
      final index = likedImages.indexOf(imagePath);
      if (index != -1) {
        likedImages.removeAt(index);
        likedNames.removeAt(index);
      }
    });
  }

  Future<void> _clearFavorites() async {
    for (var imagePath in List<String>.from(likedImages)) {
      await _databaseService.removeFavorite(imagePath);
    }
    setState(() {
      likedImages.clear();
      likedNames.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, likedImages);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Избранные', style: GoogleFonts.oswald()),
          centerTitle: true,
          actions: [
            if (likedImages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _clearFavorites,
                tooltip: 'Очистить избранное',
              ),
          ],
        ),
        body: likedImages.isEmpty
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
                itemCount: likedImages.length,
                itemBuilder: (context, index) {
                  final imagePath = likedImages[index];
                  final shoeName = likedNames[index];
                  return Dismissible(
                    key: ValueKey(imagePath),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await _removeFromFavorites(imagePath);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Удалено из избранного'),
                          action: SnackBarAction(
                            label: 'Отмена',
                            onPressed: () async {
                              await _databaseService.addFavorite(imagePath);
                              _loadLikedItems();
                            },
                          ),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Image.asset(
                          imagePath,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          shoeName,
                          style: GoogleFonts.oswald(
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
