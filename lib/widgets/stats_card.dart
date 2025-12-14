import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade200
              : Colors.grey.shade700,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.textSecondaryLight
                  : AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          if (icon != null)
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTheme.displayMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: AppTheme.displayMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
        ],
      ),
    );
  }
}

