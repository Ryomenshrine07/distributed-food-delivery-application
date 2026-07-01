import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/delivery_record.dart';

class HistoryLocalDataSource {
  static const String _tableName = 'delivery_records';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'delivery_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            orderId TEXT PRIMARY KEY,
            deliveredAt TEXT NOT NULL,
            pickupAddress TEXT NOT NULL,
            dropAddress TEXT NOT NULL,
            distanceKm REAL NOT NULL,
            payout REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertRecord(DeliveryRecord record) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'orderId': record.orderId,
        'deliveredAt': record.deliveredAt.toIso8601String(),
        'pickupAddress': record.pickupAddress,
        'dropAddress': record.dropAddress,
        'distanceKm': record.distanceKm,
        'payout': record.payout,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeliveryRecord>> getRecords({int page = 0, int pageSize = 20}) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'deliveredAt DESC',
      limit: pageSize,
      offset: page * pageSize,
    );
    return maps.map((m) => DeliveryRecord(
      orderId: m['orderId'] as String,
      deliveredAt: DateTime.parse(m['deliveredAt'] as String),
      pickupAddress: m['pickupAddress'] as String,
      dropAddress: m['dropAddress'] as String,
      distanceKm: (m['distanceKm'] as num).toDouble(),
      payout: (m['payout'] as num).toDouble(),
    )).toList();
  }

  Future<List<DeliveryRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'deliveredAt DESC');
    return maps.map((m) => DeliveryRecord(
      orderId: m['orderId'] as String,
      deliveredAt: DateTime.parse(m['deliveredAt'] as String),
      pickupAddress: m['pickupAddress'] as String,
      dropAddress: m['dropAddress'] as String,
      distanceKm: (m['distanceKm'] as num).toDouble(),
      payout: (m['payout'] as num).toDouble(),
    )).toList();
  }

  Future<int> getCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
