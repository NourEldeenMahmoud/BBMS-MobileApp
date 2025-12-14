import 'dart:async';
import '../models/mobile_user.dart';
import '../models/appointment.dart';
import '../models/donation.dart';
import '../models/notification.dart';

class MockApiService {
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Authentication
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    await _delay();
    
    // Mock validation
    if (phoneNumber == '1234567890' && password == '123456') {
      return {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'mobileUserID': 1,
          'personID': 1,
          'phoneNumber': phoneNumber,
          'fullName': 'Jane Doe',
          'email': 'jane.doe@email.com',
          'bloodType': 'O+',
          'dateOfBirth': '1990-10-25T00:00:00.000Z',
          'address': '123 Main St, City',
        },
      };
    } else {
      return {
        'success': false,
        'message': 'Invalid phone number or password',
      };
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    await _delay();
    
    // Mock validation
    final phoneNumber = userData['phoneNumber'] as String? ?? '';
    if (phoneNumber.isEmpty) {
      return false;
    }
    
    // Mock registration - always succeeds for demo
    // In real API, this would create Person, Patient/Donor, and MobileUser records
    return true;
  }

  // Appointments
  Future<List<Appointment>> getAppointments(int mobileUserID) async {
    await _delay();
    
    final now = DateTime.now();
    return [
      Appointment(
        transfusionID: 1,
        appointmentDate: now.add(const Duration(days: 5)),
        appointmentTime: '10:30:00',
        location: 'City Blood Center',
        status: 'Pending',
        quantityRequested: 450,
        patientName: 'Jane Doe',
        transfusionRequestDate: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        transfusionID: 2,
        appointmentDate: now.add(const Duration(days: 18)),
        appointmentTime: '14:00:00',
        location: 'Northside Clinic',
        status: 'Pending',
        quantityRequested: 450,
        patientName: 'Jane Doe',
        transfusionRequestDate: now.subtract(const Duration(days: 1)),
      ),
      Appointment(
        transfusionID: 3,
        appointmentDate: now.subtract(const Duration(days: 30)),
        appointmentTime: '09:00:00',
        location: 'Downtown Blood Center',
        status: 'Completed',
        quantityRequested: 450,
        patientName: 'Jane Doe',
        transfusionRequestDate: now.subtract(const Duration(days: 35)),
      ),
    ];
  }

  Future<bool> bookAppointment(Map<String, dynamic> appointmentData) async {
    await _delay();
    // Mock booking - always succeeds
    return true;
  }

  Future<bool> cancelAppointment(int transfusionID) async {
    await _delay();
    // Mock cancellation - always succeeds
    return true;
  }

  Future<bool> rescheduleAppointment(int transfusionID, DateTime newDate, String newTime) async {
    await _delay();
    // Mock reschedule - always succeeds
    return true;
  }

  // Donations
  Future<List<Donation>> getDonationHistory(int donorID) async {
    await _delay();
    
    final now = DateTime.now();
    return [
      Donation(
        donationID: 1,
        donationDate: now.subtract(const Duration(days: 90)),
        bloodVolume: 450,
        location: 'Downtown Center Branch',
      ),
      Donation(
        donationID: 2,
        donationDate: now.subtract(const Duration(days: 180)),
        bloodVolume: 450,
        location: 'Uptown Clinic',
      ),
      Donation(
        donationID: 3,
        donationDate: now.subtract(const Duration(days: 270)),
        bloodVolume: 450,
        location: 'Downtown Center Branch',
      ),
      Donation(
        donationID: 4,
        donationDate: now.subtract(const Duration(days: 360)),
        bloodVolume: 450,
        location: 'Community Hospital',
      ),
      Donation(
        donationID: 5,
        donationDate: now.subtract(const Duration(days: 450)),
        bloodVolume: 450,
        location: 'Downtown Center Branch',
      ),
    ];
  }

  Future<Map<String, dynamic>> getDonationStats(int donorID) async {
    await _delay();
    
    final donations = await getDonationHistory(donorID);
    final totalVolume = donations.fold<double>(0, (sum, d) => sum + d.bloodVolume);
    final lastDonation = donations.isNotEmpty ? donations.first.donationDate : null;
    
    return {
      'totalDonations': donations.length,
      'totalVolume': totalVolume,
      'lastDonationDate': lastDonation?.toIso8601String(),
      'livesSaved': donations.length * 3,
    };
  }

  // Profile
  Future<MobileUser> getUserProfile(int mobileUserID) async {
    await _delay();
    
    return MobileUser(
      mobileUserID: mobileUserID,
      personID: 1,
      phoneNumber: '1234567890',
      fullName: 'Jane Doe',
      email: 'jane.doe@email.com',
      bloodType: 'O+',
      dateOfBirth: DateTime(1990, 10, 25),
      address: '123 Main St, City',
    );
  }

  Future<bool> updateProfile(int mobileUserID, Map<String, dynamic> profileData) async {
    await _delay();
    // Mock update - always succeeds
    return true;
  }

  // Notifications
  Future<List<Notification>> getNotifications(int mobileUserID) async {
    await _delay();
    
    final now = DateTime.now();
    return [
      Notification(
        notificationID: 1,
        title: 'Upcoming Appointment',
        message: 'You have an appointment scheduled for tomorrow at 10:30 AM',
        type: NotificationType.appointment,
        isRead: false,
        createdDate: now.subtract(const Duration(hours: 2)),
        transfusionID: 1,
      ),
      Notification(
        notificationID: 2,
        title: "You're Eligible to Donate!",
        message: 'You can now schedule your next blood donation appointment.',
        type: NotificationType.eligibility,
        isRead: false,
        createdDate: now.subtract(const Duration(days: 1)),
      ),
      Notification(
        notificationID: 3,
        title: 'Community Impact',
        message: 'Your donation has helped save lives. Thank you!',
        type: NotificationType.communityImpact,
        isRead: true,
        createdDate: now.subtract(const Duration(days: 3)),
        donationID: 1,
      ),
      Notification(
        notificationID: 4,
        title: 'Thank You for Donating',
        message: 'We appreciate your contribution. You can donate again soon.',
        type: NotificationType.thankYou,
        isRead: true,
        createdDate: now.subtract(const Duration(days: 7)),
        donationID: 2,
      ),
    ];
  }

  Future<bool> markNotificationAsRead(int notificationID) async {
    await _delay();
    // Mock mark as read - always succeeds
    return true;
  }

  Future<bool> clearAllNotifications(int mobileUserID) async {
    await _delay();
    // Mock clear all - always succeeds
    return true;
  }
}

