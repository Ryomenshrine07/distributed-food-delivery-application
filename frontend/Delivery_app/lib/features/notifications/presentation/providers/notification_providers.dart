import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../services/push_notification_service.dart';

part 'notification_providers.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl();
}

@riverpod
PushNotificationService pushNotificationService(Ref ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return PushNotificationService(repo);
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  late final NotificationRepository _repository;

  @override
  Future<List<AppNotification>> build() async {
    _repository = ref.watch(notificationRepositoryProvider);
    return _repository.getNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    await loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    await loadNotifications();
  }
}

@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  ref.watch(notificationProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  return await repo.getUnreadCount();
}
