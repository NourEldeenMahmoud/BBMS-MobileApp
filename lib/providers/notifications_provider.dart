import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;
  List<Notification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  List<Notification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications(int mobileUserID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _apiService.getNotifications(mobileUserID);
      // Sort by date descending (newest first)
      _notifications.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int notificationID) async {
    try {
      final success = await _apiService.markNotificationAsRead(notificationID);
      if (success) {
        final index = _notifications.indexWhere((n) => n.notificationID == notificationID);
        if (index != -1) {
          _notifications[index] = Notification(
            notificationID: _notifications[index].notificationID,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            isRead: true,
            createdDate: _notifications[index].createdDate,
            transfusionID: _notifications[index].transfusionID,
            donationID: _notifications[index].donationID,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll(int mobileUserID) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.clearAllNotifications(mobileUserID);
      if (success) {
        _notifications.clear();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

