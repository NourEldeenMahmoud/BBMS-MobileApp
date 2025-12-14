import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/appointment.dart';
import '../utils/date_formatter.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onReschedule,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.formattedDate,
              style: AppTheme.titleLarge.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.appointmentTime != null
                      ? DateFormatter.formatTime(appointment.appointmentTime!)
                      : 'No time set',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.textSecondaryLight
                        : AppTheme.textSecondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.location ?? 'Location not set',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textSecondaryDark,
                    ),
                  ),
                ),
              ],
            ),
            if (onReschedule != null || onCancel != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  if (onReschedule != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onReschedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonSecondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ),
                  if (onReschedule != null && onCancel != null)
                    const SizedBox(width: 12),
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

