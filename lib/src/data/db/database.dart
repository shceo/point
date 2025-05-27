import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Future<void> addFavoriteFull(Map<String, dynamic> product) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final ref = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('favorites');

  //   await ref.doc(product['image']).set(product);
  // }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'favorites.db'),
      version: 2,
      onCreate: (db, version) async {
        // 1) Существующие таблицы
        await db.execute('''
  CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    imagePath TEXT NOT NULL,
    name TEXT,
    price REAL,
    discount TEXT
  )
''');

        await db.execute('''
            CREATE TABLE basket (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              productId TEXT,
              name TEXT,
              price REAL,
              size TEXT,
              color TEXT,
              imagePath TEXT,
              counter INTEGER DEFAULT 1
            )
          ''');

        // 2) Новая таблица истории заказов
        await db.execute('''
            CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              productId TEXT,
              name TEXT,
              price REAL,
              size TEXT,
              color TEXT,
              imagePath TEXT,
              counter INTEGER DEFAULT 1
            )
          ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Если дошли до версии 2, создаём basket (если его раньше не было)
          await db.execute('''
              CREATE TABLE IF NOT EXISTS basket (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                productId TEXT,
                name TEXT,
                price REAL,
                size TEXT,
                color TEXT,
                imagePath TEXT,
                counter INTEGER DEFAULT 1
              )
            ''');

          // И сразу же создаём таблицу orders, если её нет
          await db.execute('''
              CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                productId TEXT,
                name TEXT,
                price REAL,
                size TEXT,
                color TEXT,
                imagePath TEXT,
                counter INTEGER DEFAULT 1
              )
            ''');
        }
      },
    );
  }

  // добавим полноценный локальный метод
  Future<void> addFavoriteLocal(Map<String, dynamic> product) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'imagePath': product['image'],
        'name': product['name'],
        'price': product['price'],
        'discount': product['discount'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavoritesLocal() async {
    final db = await database;
    return await db.query('favorites');
  }

  Future<void> removeFavoriteLocal(String imagePath) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'imagePath = ?',
      whereArgs: [imagePath],
    );
  }

  Future<void> removeFavorite(String imagePath) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'imagePath = ?',
      whereArgs: [imagePath],
    );
  }

  Future<void> addToBasket({
    required String productId,
    required String name,
    required double price,
    required String size,
    required String color,
    required String imagePath,
  }) async {
    final db = await database;
    await db.insert(
      'basket',
      {
        'productId': productId,
        'name': name,
        'price': price,
        'size': size,
        'color': color,
        'imagePath': imagePath,
        'counter': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getBasketItems() async {
    final db = await database;
    final maps = await db.query('basket');
    return maps;
  }

  Future<void> updateBasketItemCounter(int id, int counter) async {
    final db = await database;
    await db.update(
      'basket',
      {'counter': counter},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> removeBasketItem(int id) async {
    final db = await database;
    await db.delete(
      'basket',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удалить корзину целиком
  Future<void> clearBasket() async {
    final db = await database;
    await db.delete('basket');
  }

  // ========== Методы для истории заказов ==========

  /// Получить все заказы
  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return db.query('orders');
  }

  /// Добавить один заказ в историю
  Future<void> addOrder(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert(
      'orders',
      {
        'productId': item['productId'],
        'name': item['name'],
        'price': item['price'],
        'size': item['size'],
        'color': item['color'],
        'imagePath': item['imagePath'],
        'counter': item['counter'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
