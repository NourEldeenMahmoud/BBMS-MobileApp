import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/notification.dart' as models;

class NotificationCard extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case models.NotificationType.appointment:
        return Icons.calendar_month;
      case models.NotificationType.eligibility:
        return Icons.check_circle;
      case models.NotificationType.thankYou:
        return Icons.favorite;
      case models.NotificationType.communityImpact:
        return Icons.newspaper;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(BuildContext context) {
    if (notification.isRead) {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade600
          : Colors.grey.shade400;
    }
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? (Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade200
                          : Colors.grey.shade800)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (notification.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTheme.bodySmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppTheme.textSecondaryLight
                              : AppTheme.textSecondaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Text(
                  notification.relativeTime,
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.textSecondaryLight
                        : AppTheme.textSecondaryDark,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

