import '../models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';

/// Notification data source interface
abstract class NotificationDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount();
}

/// Mock notification data source implementation
class NotificationDataSourceImpl implements NotificationDataSource {
  // Mock data - will be replaced with API calls later
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      category: 'Payment Received',
      title: 'Earn 5% Cashback on Grocery Purchases this Weekend!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 34)),
      isRead: false,
      type: NotificationType.payment,
    ),
    NotificationModel(
      id: '2',
      category: 'Payment Reminder',
      title: 'Diversify Your Portfolio with Emerging Markets Fund',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      type: NotificationType.reminder,
    ),
    NotificationModel(
      id: '3',
      category: 'Security Alert',
      title: 'Suspicious Login Attempt Detected on Your Account',
      createdAt: DateTime.now().subtract(const Duration(minutes: 52)),
      isRead: true,
      type: NotificationType.security,
    ),
    NotificationModel(
      id: '4',
      category: 'Loan Reminder',
      title: 'Your Mortgage Payment is Due in 3 Days',
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      isRead: false,
      type: NotificationType.loan,
    ),
    NotificationModel(
      id: '5',
      category: 'Budget Advisory',
      title: '80% of Your Monthly Budget Spent - Time for Expense Review!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
      isRead: false,
      type: NotificationType.budget,
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockNotifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = NotificationModel(
        id: _mockNotifications[index].id,
        category: _mockNotifications[index].category,
        title: _mockNotifications[index].title,
        description: _mockNotifications[index].description,
        createdAt: _mockNotifications[index].createdAt,
        isRead: true,
        type: _mockNotifications[index].type,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = NotificationModel(
        id: _mockNotifications[i].id,
        category: _mockNotifications[i].category,
        title: _mockNotifications[i].title,
        description: _mockNotifications[i].description,
        createdAt: _mockNotifications[i].createdAt,
        isRead: true,
        type: _mockNotifications[i].type,
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotifications.where((n) => !n.isRead).length;
  }
}
