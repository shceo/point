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

class _CardScreenState extends State<CardScreen>
    with SingleTickerProviderStateMixin {
  int selectedSize = 42;
  Color selectedColor = Colors.red;
  final List<Color> colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.black,
  ];

  final List<int> availableSizes = [41, 42, 43, 44, 45];

  final DatabaseService _databaseService = DatabaseService();


  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _animController.reverse();
          });
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _addToBasket() async {
    // Преобразуем выбранный цвет в строку
    String colorStr;
    if (selectedColor == Colors.blue) {
      colorStr = 'синий';
    } else if (selectedColor == Colors.red) {
      colorStr = 'красный';
    } else if (selectedColor == Colors.green) {
      colorStr = 'зелёный';
    } else if (selectedColor == Colors.orange) {
      colorStr = 'оранжевый';
    } else {
      colorStr = 'чёрный';
    }

    double price = double.tryParse(widget.product['price'].toString()) ?? 0.0;

    await _databaseService.addToBasket(
      productId: widget.product['id'] ?? '',
      name: widget.product['name'] ?? '',
      price: price,
      size: selectedSize.toString(),
      color: colorStr,
      imagePath: widget.product['image'] ?? '',
    );

    // Запускаем анимацию «падения» товара
    _animController.forward();

    // Показываем сообщение об успешном добавлении
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Товар успешно добавлен в корзину'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoeName = widget.product['name'] ?? '';
    final shoeImage = widget.product['image'] ?? '';
    final double price =
        double.tryParse(widget.product['price'].toString()) ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
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

            // Основная часть: цвета, изображение, размеры
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Блок выбора цвета
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Цвет',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
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
                                    height: 35,
                                    width: 35,
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
                  ),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/text.png',
                            height: 400,
                            fit: BoxFit.contain,
                          ),
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              final double value = _animController.value;

                              // движение вниз по кривой
                              final dy = value * 300;
                              // масштаб с 1.0 до 0.8
                              final scale = 1.0 - value * 0.2;
                              // поворот до 15 градусов
                              final angle = value * 15 * math.pi / 180;

                              return Transform.translate(
                                offset: Offset(0, dy),
                                child: Transform.rotate(
                                  angle: angle,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Transform.rotate(
                              angle: -50 * math.pi / 180,
                              child: Draggable<Map<String, dynamic>>(
                                data: widget.product,
                                feedback: Opacity(
                                  opacity: 0.8,
                                  child: Image.asset(
                                    shoeImage,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.4,
                                  child: Image.asset(
                                    shoeImage,
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                child: Image.asset(
                                  shoeImage,
                                  height: 400,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Блок выбора размера
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, top: 16.0),
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
                              width: 43,
                              height: 43,
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
                ],
              ),
            ),

            // Цена и скидка
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${price.toStringAsFixed(0)} ₽',
                      style: GoogleFonts.oswald(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.product.containsKey('discount'))
                      Text(
                        'СКИДКА ${widget.product['discount']}%',
                        style: GoogleFonts.oswald(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DragTarget + кнопка «Добавить в корзину»
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DragTarget<Map<String, dynamic>>(
                onAccept: (_) => _addToBasket(),
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: _addToBasket,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 2.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 18),
                                Icon(
                                  Icons.keyboard_double_arrow_down_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Добавить в корзину',
                            style: GoogleFonts.oswald(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            height: 185,
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
