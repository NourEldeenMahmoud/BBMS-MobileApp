import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/donation.dart';

class DonationCard extends StatelessWidget {
  final Donation donation;

  const DonationCard({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
              ),
              child: Icon(
                Icons.calendar_month,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.formattedDate,
                    style: AppTheme.titleMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donation.location ?? 'Location not specified',
                    style: AppTheme.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.textSecondaryLight
                          : AppTheme.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${donation.bloodVolume.toInt()} mL',
              style: AppTheme.titleMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

