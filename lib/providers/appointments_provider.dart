import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AppointmentsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  List<Appointment> get upcomingAppointments =>
      _appointments.where((a) => a.isUpcoming).toList();
  List<Appointment> get pastAppointments =>
      _appointments.where((a) => a.isPast).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Appointment? get nextAppointment {
    final upcoming = upcomingAppointments;
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return upcoming.first;
  }

  Future<void> loadAppointments(int mobileUserID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _apiService.getAppointments(mobileUserID);
    } catch (e) {
      _error = 'Failed to load appointments: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookAppointment({
    required int mobileUserID,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String location,
    required int quantityRequested,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.bookAppointment({
        'mobileUserID': mobileUserID,
        'appointmentDate': appointmentDate.toIso8601String(),
        'appointmentTime': appointmentTime,
        'location': location,
        'quantityRequested': quantityRequested,
      });

      if (success) {
        // Reload appointments
        await loadAppointments(mobileUserID);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to book appointment';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Extract error message from exception
      String errorMessage = 'Error booking appointment';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().split('Exception:').last.trim();
      } else {
        errorMessage = e.toString();
      }
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(int transfusionID, int mobileUserID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.cancelAppointment(transfusionID);
      if (success) {
        _appointments.removeWhere((a) => a.transfusionID == transfusionID);
      } else {
        _error = 'Failed to cancel appointment';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error canceling appointment: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rescheduleAppointment(
    int transfusionID,
    DateTime newDate,
    String newTime,
    int mobileUserID,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.rescheduleAppointment(
        transfusionID,
        newDate,
        newTime,
      );

      if (success) {
        // Reload appointments
        await loadAppointments(mobileUserID);
      } else {
        _error = 'Failed to reschedule appointment';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error rescheduling appointment: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

