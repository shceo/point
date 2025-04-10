import 'dart:math' as math; // Для поворота изображения
import 'package:davlat/src/data/db/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const CardScreen({super.key, required this.product});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final List<double> availableSizes = [9, 9.5, 10, 11];
  double selectedSize = 9.5;
  Color selectedColor = Colors.red;

  final List<Color> colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.black,
  ];

  final DatabaseService _databaseService = DatabaseService();

  void _addToBasket() async {
    String colorStr = selectedColor == Colors.blue ? 'синий' : 'красный';
    double price = double.tryParse(widget.product['price'].toString()) ?? 0.0;
    await _databaseService.addToBasket(
      productId: widget.product['id'] ?? '',
      name: widget.product['name'] ?? '',
      price: price,
      size: selectedSize.toString(),
      color: colorStr,
      imagePath: widget.product['image'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoeName = widget.product['name'] ?? 'Air Max 270';
    final shoeImage = widget.product['image'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель с кнопкой назад и названием
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  // Text(
                  //   'Мужской',
                  //   style: GoogleFonts.oswald(
                  //     color: Colors.black,
                  //     fontSize: 18,
                  //   ),
                  // ),
                  const Spacer(),
                  Text(
                    shoeName,
                    style: GoogleFonts.oswald(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Список размеров
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Размер',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final size in availableSizes)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSize = size;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              width: 45,
                              height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedSize == size
                                    ? Colors.blue
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                size.toString(),
                                style: TextStyle(
                                  color: selectedSize == size
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -30),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              child: Image.asset(
                                'assets/images/text.png',
                                height: 480,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Transform.rotate(
                              angle: -50 * math.pi / 180,
                              child: Draggable<Map<String, dynamic>>(
                                data: widget.product,
                                feedback: Opacity(
                                  opacity: 0.8,
                                  child: Image.asset(
                                    shoeImage,
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.4,
                                  child: Image.asset(
                                    shoeImage,
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                child: Image.asset(
                                  shoeImage,
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Выбор цвета
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Цвет',
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        width: 50,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: colorOptions.map((color) {
                              final isSelected = color == selectedColor;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Цена и скидка
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    '\t\t\$30.99\t',
                    style: GoogleFonts.oswald(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\t\tСКИДКА 10%',
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // DragTarget с картинкой box.png и контейнером с иконками, который теперь расположен над картиной
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DragTarget<Map<String, dynamic>>(
                onAcceptWithDetails: (data) {
                  _addToBasket();
                },
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: _addToBasket,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 2.0),
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          // Контейнер с двумя иконками (сверху)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white),
                                SizedBox(width: 18),
                                Icon(Icons.keyboard_double_arrow_down_rounded,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Текст между контейнером с иконками и картинкой
                          Text(
                            'Добавить в корзину',
                            style: GoogleFonts.oswald(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            height: 170,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/box.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
