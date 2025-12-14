import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/profile_provider.dart';
import '../providers/donations_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/eligibility_calculator.dart';
import '../widgets/custom_button.dart';
import '../routes/app_router.dart';
import '../utils/error_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      Provider.of<ProfileProvider>(context, listen: false).loadProfile(user.mobileUserID);
      Provider.of<DonationsProvider>(context, listen: false).loadAll(user.mobileUserID);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.login,
          (route) => false,
        );
        ErrorHandler.showSuccess(context, 'Logged out successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).cardColor,
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  final user = profileProvider.user;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'Loading...',
                        style: AppTheme.displayMedium.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppTheme.textSecondaryLight
                              : AppTheme.textSecondaryDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Personal Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Details',
                    style: AppTheme.titleLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    Icons.phone,
                    'Phone Number',
                    Provider.of<AuthProvider>(context).currentUser?.phoneNumber ?? '',
                  ),
                  _buildDetailCard(
                    context,
                    Icons.bloodtype,
                    'Blood Type',
                    Provider.of<ProfileProvider>(context).user?.bloodType ?? '',
                  ),
                  _buildDetailCard(
                    context,
                    Icons.cake,
                    'Date of Birth',
                    Provider.of<ProfileProvider>(context).user?.dateOfBirth != null
                        ? DateFormatter.formatDate(
                            Provider.of<ProfileProvider>(context).user!.dateOfBirth!)
                        : '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Donation Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Donation Statistics',
                    style: AppTheme.titleLarge.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<DonationsProvider>(
                    builder: (context, donationsProvider, _) {
                      final stats = donationsProvider.stats;
                      final totalDonations = stats['totalDonations'] as int? ?? 0;
                      final livesSaved = stats['livesSaved'] as int? ?? 0;
                      final lastDonationDate = stats['lastDonationDate'] != null
                          ? DateTime.parse(stats['lastDonationDate'] as String)
                          : null;
                      final nextEligible = EligibilityCalculator.getNextEligibleDate(lastDonationDate);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '$totalDonations',
                                        style: AppTheme.displayLarge.copyWith(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'Total Donations',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppTheme.textSecondaryLight
                                              : AppTheme.textSecondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '$livesSaved',
                                        style: AppTheme.displayLarge.copyWith(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'Lives Saved',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppTheme.textSecondaryLight
                                              : AppTheme.textSecondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Column(
                              children: [
                                Text(
                                  'Last Donation',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? AppTheme.textSecondaryLight
                                        : AppTheme.textSecondaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastDonationDate != null
                                      ? DateFormatter.formatDate(lastDonationDate)
                                      : 'Never',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  'Next Eligible',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? AppTheme.textSecondaryLight
                                        : AppTheme.textSecondaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextEligible != null
                                      ? DateFormatter.formatDate(nextEligible)
                                      : 'Now',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: 'Edit Profile',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.editProfile);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: 'Logout',
                onPressed: _handleLogout,
                backgroundColor: Colors.red,
                isOutlined: false,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.textSecondaryLight
                        : AppTheme.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

