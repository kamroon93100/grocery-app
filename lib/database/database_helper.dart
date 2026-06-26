import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        email      TEXT    UNIQUE NOT NULL,
        password   TEXT    NOT NULL,
        phone      TEXT    DEFAULT "",
        address    TEXT    DEFAULT "",
        is_admin   INTEGER DEFAULT 0,
        created_at TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableProducts} (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL,
        category     TEXT    NOT NULL,
        image        TEXT    DEFAULT "",
        price        REAL    NOT NULL,
        discount     REAL    DEFAULT 0,
        stock        INTEGER DEFAULT 100,
        description  TEXT    DEFAULT "",
        is_available INTEGER DEFAULT 1,
        created_at   TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableOrders} (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id          INTEGER NOT NULL,
        user_name        TEXT    NOT NULL,
        user_phone       TEXT    NOT NULL,
        delivery_address TEXT    NOT NULL,
        items            TEXT    NOT NULL,
        total_amount     REAL    NOT NULL,
        status           TEXT    DEFAULT "Pending",
        payment_method   TEXT    DEFAULT "Cash on Delivery",
        notes            TEXT    DEFAULT "",
        created_at       TEXT    NOT NULL
      )
    ''');

    await db.insert(AppConstants.tableUsers, {
      'name':       'Admin',
      'email':      'admin@grocery.com',
      'password':   _hashPassword('admin123'),
      'phone':      '0000000000',
      'address':    'Store',
      'is_admin':   1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _insertDefaultProducts(db);
  }

  String _hashPassword(String password) {
    final bytes  = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _insertDefaultProducts(Database db) async {
    final now = DateTime.now().toIso8601String();
    final products = [
      ['Tomatoes',  'Vegetables', '🍅', 2.99,  0.0 ],
      ['Onions',    'Vegetables', '🧅', 1.49,  5.0 ],
      ['Potatoes',  'Vegetables', '🥔', 1.99,  0.0 ],
      ['Carrots',   'Vegetables', '🥕', 1.29,  10.0],
      ['Spinach',   'Vegetables', '🥬', 1.99,  0.0 ],
      ['Bananas',   'Fruits',     '🍌', 1.99,  0.0 ],
      ['Apples',    'Fruits',     '🍎', 3.49,  5.0 ],
      ['Oranges',   'Fruits',     '🍊', 2.79,  0.0 ],
      ['Grapes',    'Fruits',     '🍇', 4.99,  15.0],
      ['Mango',     'Fruits',     '🥭', 3.99,  0.0 ],
      ['Milk',      'Dairy',      '🥛', 2.29,  0.0 ],
      ['Eggs',      'Dairy',      '🥚', 2.89,  0.0 ],
      ['Butter',    'Dairy',      '🧈', 3.49,  5.0 ],
      ['Cheese',    'Dairy',      '🧀', 4.99,  0.0 ],
      ['Yogurt',    'Dairy',      '🍦', 2.49,  10.0],
      ['Chicken',   'Meat',       '🍗', 8.99,  0.0 ],
      ['Beef',      'Meat',       '🥩', 10.99, 5.0 ],
      ['Fish',      'Meat',       '🐟', 7.99,  0.0 ],
      ['Rice',      'Grains',     '🍚', 4.49,  0.0 ],
      ['Bread',     'Bakery',     '🍞', 2.49,  0.0 ],
      ['Cake',      'Bakery',     '🎂', 8.99,  10.0],
      ['Water',     'Beverages',  '💧', 0.99,  0.0 ],
      ['Juice',     'Beverages',  '🧃', 2.99,  5.0 ],
      ['Chips',     'Snacks',     '🍟', 1.99,  0.0 ],
      ['Chocolate', 'Snacks',     '🍫', 2.49,  15.0],
    ];

    for (var p in products) {
      await db.insert(AppConstants.tableProducts, {
        'name':         p[0],
        'category':     p[1],
        'image':        p[2],
        'price':        p[3],
        'discount':     p[4],
        'stock':        100,
        'description':  '${p[0]} - Fresh and quality',
        'is_available': 1,
        'created_at':   now,
      });
    }
  }

  // USER METHODS
  Future<UserModel?> registerUser(UserModel user) async {
    final db = await database;
    try {
      final id = await db.insert(AppConstants.tableUsers, {
        'name':       user.name,
        'email':      user.email.toLowerCase(),
        'password':   _hashPassword(user.password),
        'phone':      user.phone,
        'address':    user.address,
        'is_admin':   0,
        'created_at': DateTime.now().toIso8601String(),
      });
      user.id = id;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db     = await database;
    final hashed = _hashPassword(password);
    final result = await db.query(
      AppConstants.tableUsers,
      where:     'email = ? AND password = ?',
      whereArgs: [email.toLowerCase(), hashed],
    );
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  Future<bool> updateUser(UserModel user) async {
    final db   = await database;
    final rows = await db.update(
      AppConstants.tableUsers,
      {'name': user.name, 'phone': user.phone, 'address': user.address},
      where:     'id = ?',
      whereArgs: [user.id],
    );
    return rows > 0;
  }

  Future<bool> changePassword(int userId, String oldPass, String newPass) async {
    final db      = await database;
    final oldHash = _hashPassword(oldPass);
    final check   = await db.query(
      AppConstants.tableUsers,
      where:     'id = ? AND password = ?',
      whereArgs: [userId, oldHash],
    );
    if (check.isEmpty) return false;
    await db.update(
      AppConstants.tableUsers,
      {'password': _hashPassword(newPass)},
      where:     'id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db     = await database;
    final result = await db.query(AppConstants.tableUsers);
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  // PRODUCT METHODS
  Future<List<ProductModel>> getAllProducts() async {
    final db     = await database;
    final result = await db.query(
      AppConstants.tableProducts,
      where: 'is_available = 1',
    );
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db     = await database;
    final result = await db.query(
      AppConstants.tableProducts,
      where:     'name LIKE ? AND is_available = 1',
      whereArgs: ['%$query%'],
    );
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> addProduct(ProductModel product) async {
    final db = await database;
    return await db.insert(AppConstants.tableProducts, product.toMap());
  }

  Future<bool> updateProduct(ProductModel product) async {
    final db   = await database;
    final rows = await db.update(
      AppConstants.tableProducts,
      product.toMap(),
      where:     'id = ?',
      whereArgs: [product.id],
    );
    return rows > 0;
  }

  Future<bool> deleteProduct(int id) async {
    final db   = await database;
    final rows = await db.update(
      AppConstants.tableProducts,
      {'is_available': 0},
      where:     'id = ?',
      whereArgs: [id],
    );
    return rows > 0;
  }

  // ORDER METHODS
  Future<int> placeOrder(OrderModel order) async {
    final db       = await database;
    final itemsStr = order.items
        .map((i) => '${i.productId}:${i.productName}:${i.price}:${i.quantity}')
        .join('||');
    return await db.insert(AppConstants.tableOrders, {
      'user_id':          order.userId,
      'user_name':        order.userName,
      'user_phone':       order.userPhone,
      'delivery_address': order.deliveryAddress,
      'items':            itemsStr,
      'total_amount':     order.totalAmount,
      'status':           order.status,
      'payment_method':   order.paymentMethod,
      'notes':            order.notes,
      'created_at':       order.createdAt,
    });
  }

  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    final db = await database;
    return await db.query(
      AppConstants.tableOrders,
      where:     'user_id = ?',
      whereArgs: [userId],
      orderBy:   'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return await db.query(
      AppConstants.tableOrders,
      orderBy: 'created_at DESC',
    );
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    final db   = await database;
    final rows = await db.update(
      AppConstants.tableOrders,
      {'status': status},
      where:     'id = ?',
      whereArgs: [orderId],
    );
    return rows > 0;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db            = await database;
    final totalOrders   = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableOrders}')) ?? 0;
    final revenueResult = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM ${AppConstants.tableOrders}');
    final totalRevenue  = (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final totalUsers    = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tableUsers} WHERE is_admin = 0')) ?? 0;
    final totalProducts = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tableProducts} WHERE is_available = 1')) ?? 0;
    final pendingOrders = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.tableOrders} WHERE status = "Pending"')) ?? 0;
    return {
      'totalOrders':   totalOrders,
      'totalRevenue':  totalRevenue,
      'totalUsers':    totalUsers,
      'totalProducts': totalProducts,
      'pendingOrders': pendingOrders,
    };
  }
}
