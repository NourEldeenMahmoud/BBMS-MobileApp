import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/appointments_provider.dart';
import '../providers/donations_provider.dart';
import '../providers/notifications_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/eligibility_calculator.dart';
import '../routes/app_router.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      Provider.of<AppointmentsProvider>(context, listen: false)
          .loadAppointments(user.mobileUserID);
      Provider.of<DonationsProvider>(context, listen: false)
          .loadAll(user.mobileUserID);
      Provider.of<NotificationsProvider>(context, listen: false)
          .loadNotifications(user.mobileUserID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.bloodtype,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Home',
                      style: AppTheme.titleLarge.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Consumer<NotificationsProvider>(
                    builder: (context, notificationsProvider, _) {
                      final unreadCount = notificationsProvider.unreadCount;
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.notifications);
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final userName = authProvider.currentUser?.fullName ?? 'User';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTheme.displayLarge.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              '$userName!',
                              style: AppTheme.displayLarge.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Stats Cards
                    Consumer<DonationsProvider>(
                      builder: (context, donationsProvider, _) {
                        final stats = donationsProvider.stats;
                        final totalDonations = stats['totalDonations'] as int? ?? 0;
                        final lastDonationDate = stats['lastDonationDate'] != null
                            ? DateTime.parse(stats['lastDonationDate'] as String)
                            : null;
                        final isEligible = EligibilityCalculator.isEligibleToDonate(lastDonationDate);

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatsCard(
                                    label: 'Total Donations',
                                    value: '$totalDonations times',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatsCard(
                                    label: 'Last Donated',
                                    value: lastDonationDate != null
                                        ? DateFormatter.formatDate(lastDonationDate)
                                        : 'Never',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            StatsCard(
                              label: 'Eligibility',
                              value: isEligible ? 'Eligible' : 'Not Eligible',
                              icon: isEligible ? Icons.check_circle : Icons.cancel,
                              iconColor: isEligible ? Colors.green : Colors.red,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Upcoming Appointment Card
                    Consumer<AppointmentsProvider>(
                      builder: (context, appointmentsProvider, _) {
                        final nextAppointment = appointmentsProvider.nextAppointment;
                        if (nextAppointment != null) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Upcoming Appointment',
                                        style: AppTheme.titleMedium.copyWith(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        nextAppointment.formattedDate,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppTheme.textSecondaryLight
                                              : AppTheme.textSecondaryDark,
                                        ),
                                      ),
                                      Text(
                                        nextAppointment.appointmentTime != null
                                            ? DateFormatter.formatTime(nextAppointment.appointmentTime!)
                                            : '',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppTheme.textSecondaryLight
                                              : AppTheme.textSecondaryDark,
                                        ),
                                      ),
                                      Text(
                                        nextAppointment.location ?? '',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppTheme.textSecondaryLight
                                              : AppTheme.textSecondaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(AppRouter.myAppointments);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                          foregroundColor: AppTheme.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text('View Details'),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: AppTheme.primaryColor,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 32),
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: AppTheme.titleLarge.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildQuickActionCard(
                          context,
                          'Book Appointment',
                          Icons.edit_calendar,
                          AppTheme.primaryColor,
                          () => Navigator.of(context).pushNamed(AppRouter.bookAppointment),
                        ),
                        _buildQuickActionCard(
                          context,
                          'My Appointments',
                          Icons.event_note,
                          null,
                          () => Navigator.of(context).pushNamed(AppRouter.myAppointments),
                        ),
                        _buildQuickActionCard(
                          context,
                          'Donation History',
                          Icons.history,
                          null,
                          () => Navigator.of(context).pushNamed(AppRouter.donationHistory),
                        ),
                        _buildQuickActionCard(
                          context,
                          'Profile',
                          Icons.person,
                          null,
                          () => Navigator.of(context).pushNamed(AppRouter.profile),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Colors.grey.shade700,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(context, Icons.home, 'Home', true, () {}),
                _buildBottomNavItem(
                  context,
                  Icons.calendar_month,
                  'Appointments',
                  false,
                  () => Navigator.of(context).pushNamed(AppRouter.myAppointments),
                ),
                _buildBottomNavItem(
                  context,
                  Icons.person,
                  'Profile',
                  false,
                  () => Navigator.of(context).pushNamed(AppRouter.profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color? backgroundColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: backgroundColor == null
              ? Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade200
                      : Colors.grey.shade700,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: backgroundColor != null
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: backgroundColor != null
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppTheme.primaryColor
                : (Theme.of(context).brightness == Brightness.light
                    ? AppTheme.textSecondaryLight
                    : AppTheme.textSecondaryDark),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isActive
                  ? AppTheme.primaryColor
                  : (Theme.of(context).brightness == Brightness.light
                      ? AppTheme.textSecondaryLight
                      : AppTheme.textSecondaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

