import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/appointments_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/appointment_card.dart';
import '../routes/app_router.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  void _loadAppointments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      Provider.of<AppointmentsProvider>(context, listen: false)
          .loadAppointments(user.mobileUserID);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelAppointment(int transfusionID) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        final success = await appointmentsProvider.cancelAppointment(
          transfusionID,
          user.mobileUserID,
        );

        if (success && mounted) {
          ErrorHandler.showSuccess(context, 'Appointment cancelled successfully');
        } else if (mounted) {
          ErrorHandler.showError(
            context,
            appointmentsProvider.error ?? 'Failed to cancel appointment',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade200
                      : Colors.grey.shade700,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.textSecondaryLight
                  : AppTheme.textSecondaryDark,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(true),
                _buildAppointmentsList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(bool isUpcoming) {
    return Consumer<AppointmentsProvider>(
      builder: (context, appointmentsProvider, _) {
        final appointments = isUpcoming
            ? appointmentsProvider.upcomingAppointments
            : appointmentsProvider.pastAppointments;

        if (appointmentsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${isUpcoming ? 'Upcoming' : 'Past'} Appointments',
                  style: AppTheme.titleLarge.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isUpcoming
                      ? 'You have no upcoming appointments scheduled.'
                      : 'You have no past appointments.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.textSecondaryLight
                        : AppTheme.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return AppointmentCard(
              appointment: appointment,
              onReschedule: isUpcoming
                  ? () {
                      // TODO: Implement reschedule
                      Navigator.of(context).pushNamed(AppRouter.bookAppointment);
                    }
                  : null,
              onCancel: isUpcoming
                  ? () => _cancelAppointment(appointment.transfusionID)
                  : null,
            );
          },
        );
      },
    );
  }
}

