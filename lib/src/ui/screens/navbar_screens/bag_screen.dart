import 'dart:async';
import 'package:davlat/src/data/db/database.dart';
import 'package:davlat/src/ui/screens/payment_screen.dart';
import 'package:flutter/material.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> bagItems = [];

  @override
  void initState() {
    super.initState();
    _loadBagItems();
  }

  Future<void> _loadBagItems() async {
    final items = await _databaseService.getBasketItems();
    setState(() {
      bagItems = items.map((item) => Map<String, dynamic>.from(item)).toList();
    });
  }

  void _incrementCounter(int index) async {
    var item = bagItems[index];
    int newCounter = (item['counter'] ?? 1) + 1;
    await _databaseService.updateBasketItemCounter(item['id'], newCounter);
    setState(() {
      bagItems[index] = Map<String, dynamic>.from(bagItems[index]);
      bagItems[index]['counter'] = newCounter;
    });
  }

  void _decrementCounter(int index) async {
    var item = bagItems[index];
    int currentCounter = item['counter'] ?? 1;
    if (currentCounter > 1) {
      int newCounter = currentCounter - 1;
      await _databaseService.updateBasketItemCounter(item['id'], newCounter);
      setState(() {
        bagItems[index] = Map<String, dynamic>.from(bagItems[index]);
        bagItems[index]['counter'] = newCounter;
      });
    }
  }

  void _removeItem(int index) async {
    var item = bagItems[index];
    await _databaseService.removeBasketItem(item['id']);
    setState(() {
      bagItems.removeAt(index);
    });
  }

  double _calculateTotal() {
    return bagItems.fold(0.0, (sum, item) {
      return sum + (item['price'] ?? 0.0) * (item['counter'] ?? 1);
    });
  }

  /// Показывает диалог выбора параметров (в данном случае — пола)
  Future<void> _showParameterDialog(int index) async {
    String? selectedGender = bagItems[index]['gender'];
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Выберите пол"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Мужской"),
                value: "Мужской",
                groupValue: selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    selectedGender = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text("Женский"),
                value: "Женский",
                groupValue: selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    selectedGender = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
    if (selectedGender != null) {
      setState(() {
        bagItems[index]['gender'] = selectedGender;
        // При необходимости можно сохранить параметры в БД:
        // _databaseService.updateBasketItemParameter(bagItems[index]['id'], 'gender', selectedGender);
      });
    }
  }

  /// Проверяет, что у всех товаров выбран пол, иначе выводит предупреждение
  void _onPayPressed() {
    bool allParamsSelected = true;
    for (var item in bagItems) {
      if (item['gender'] == null) {
        allParamsSelected = false;
        break;
      }
    }
    if (!allParamsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Не выбраны все параметры обуви. Пожалуйста, нажмите на товар, чтобы выбрать."),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (bagItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Корзина пуста"),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentScreen(totalAmount: _calculateTotal())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotal();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          bagItems.isEmpty
              ? const Center(
                  child: Text(
                    'Корзина пуста',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: bagItems.length,
                  itemBuilder: (context, index) {
                    final item = bagItems[index];
                    final image = item['imagePath'] ?? '';
                    final name = item['name'] ?? 'Без имени';
                    final price = item['price'] ?? 0;
                    final counter = item['counter'] ?? 1;
                    // Оборачиваем в InkWell для обработки клика
                    return Dismissible(
                      key: ValueKey(item['id'].toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeItem(index),
                      background: Container(
                        color: Colors.black,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showParameterDialog(index),
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Image.asset(
                                  image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${(price * counter).toStringAsFixed(2)} \$',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Показываем выбранный пол (если есть)
                                      if (item['gender'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            "Пол: ${item['gender']}",
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => _decrementCounter(index),
                                    ),
                                    Text(
                                      '$counter',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () => _incrementCounter(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Весь ваш товар',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} \$',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onPressed: _onPayPressed,
                    child: const Text(
                      'Оплатить',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
