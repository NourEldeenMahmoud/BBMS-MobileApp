import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/donations_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/donation_card.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      Provider.of<DonationsProvider>(context, listen: false).loadAll(user.mobileUserID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<DonationsProvider>(
        builder: (context, donationsProvider, _) {
          if (donationsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = donationsProvider.donations;
          final totalVolume = donationsProvider.totalVolume;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Summary
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Donations',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppTheme.textSecondaryLight
                                    : AppTheme.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${donations.length}',
                              style: AppTheme.displayLarge.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Volume',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppTheme.textSecondaryLight
                                    : AppTheme.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${totalVolume.toInt()} mL',
                              style: AppTheme.displayLarge.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Donation History List
                if (donations.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Donations Yet',
                          style: AppTheme.titleLarge.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your life-saving journey today.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppTheme.textSecondaryLight
                                : AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...donations.map((donation) => DonationCard(donation: donation)),
              ],
            ),
          );
        },
      ),
    );
  }
}

