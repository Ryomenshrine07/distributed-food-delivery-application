import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Future<void> deleteNotification(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<AppNotification>> getNotifications({int limit = 50, int offset = 0}) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((json) {
      return AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        isRead: (json['isRead'] as int) == 1,
        data: json['data'] != null ? jsonDecode(json['data'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM notifications WHERE isRead = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> markAllAsRead() async {
    final db = await _databaseHelper.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'isRead = ?',
      whereArgs: [0],
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> saveNotification(AppNotification notification) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'notifications',
      {
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'timestamp': notification.timestamp.millisecondsSinceEpoch,
        'isRead': notification.isRead ? 1 : 0,
        'data': notification.data != null ? jsonEncode(notification.data) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
