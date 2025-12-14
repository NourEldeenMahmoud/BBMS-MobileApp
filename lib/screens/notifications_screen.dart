import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/notifications_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/notification_card.dart';
import '../utils/error_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      Provider.of<NotificationsProvider>(context, listen: false)
          .loadNotifications(user.mobileUserID);
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        final success = await notificationsProvider.clearAll(user.mobileUserID);
        if (success && mounted) {
          ErrorHandler.showSuccess(context, 'All notifications cleared');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, _) {
              if (notificationsProvider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: _clearAll,
                child: Text(
                  'Clear',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notificationsProvider, _) {
          if (notificationsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationsProvider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: AppTheme.titleLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have no notifications at this time.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () async {
                  if (!notification.isRead) {
                    await notificationsProvider.markAsRead(notification.notificationID);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

