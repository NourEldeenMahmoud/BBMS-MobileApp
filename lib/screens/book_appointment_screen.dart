import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../config/theme.dart';
import '../providers/appointments_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  final List<String> _timeSlots = [
    '09:00:00',
    '09:30:00',
    '10:00:00',
    '10:30:00',
    '11:00:00',
    '11:30:00',
    '14:00:00',
    '14:30:00',
    '15:00:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _confirmAppointment() async {
    if (_selectedDay == null || _selectedTime == null) {
      ErrorHandler.showError(context, 'Please select both date and time');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentsProvider = Provider.of<AppointmentsProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ErrorHandler.showError(context, 'User not found');
      return;
    }

    final success = await appointmentsProvider.bookAppointment(
      mobileUserID: user.mobileUserID,
      appointmentDate: _selectedDay!,
      appointmentTime: _selectedTime!,
      location: 'City Blood Center',
      quantityRequested: 450,
    );

    if (success && mounted) {
      ErrorHandler.showSuccess(context, 'Appointment booked successfully!');
      Navigator.of(context).pop();
    } else if (mounted) {
      ErrorHandler.showError(
        context,
        appointmentsProvider.error ?? 'Failed to book appointment',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Date Section
                  Text(
                    'Select a Date',
                    style: AppTheme.displayMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Select Time Section
                  Text(
                    'Select a Time',
                    style: AppTheme.displayMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return ChoiceChip(
                        label: Text(DateFormatter.formatTime(time)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTime = selected ? time : null;
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Information Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before You Donate',
                          style: AppTheme.titleLarge.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          context,
                          Icons.check_circle,
                          'Eat a healthy meal and be well-hydrated before donating.',
                        ),
                        _buildInfoItem(
                          context,
                          Icons.check_circle,
                          'Bring a valid photo ID with you to the appointment.',
                        ),
                        _buildInfoItem(
                          context,
                          Icons.check_circle,
                          'Ensure you are feeling well and healthy on the day of donation.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Consumer<AppointmentsProvider>(
              builder: (context, appointmentsProvider, _) {
                return CustomButton(
                  text: 'Confirm Appointment',
                  onPressed: appointmentsProvider.isLoading ? null : _confirmAppointment,
                  isLoading: appointmentsProvider.isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.textSecondaryLight
                    : AppTheme.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

