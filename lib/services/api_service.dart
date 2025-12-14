import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mobile_user.dart';
import '../models/appointment.dart';
import '../models/donation.dart';
import '../models/notification.dart';
import 'storage_service.dart';

class ApiService {
  // Web API base URL - Update this with your computer's IP address
  // Current IP from ipconfig: 192.168.1.2 (Wi-Fi adapter)
  static const String baseUrl = 'http://192.168.1.2:5000/api';
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'nationalNo': userData['nationalNo'], // Optional - will be auto-generated if not provided
          'phoneNumber': userData['phoneNumber'] ?? '',
          'password': userData['password'] ?? '',
          'firstName': userData['firstName'] ?? '',
          'lastName': userData['lastName'] ?? '',
          'secondName': userData['secondName'],
          'thirdName': userData['thirdName'],
          'email': userData['email'] ?? '',
          'bloodType': userData['bloodType'] ?? '',
          'dateOfBirth': userData['dateOfBirth'] ?? '',
          'address': userData['address'],
          'imagePath': userData['imagePath'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Appointments
  Future<List<Appointment>> getAppointments(int mobileUserID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/user/$mobileUserID'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['appointments'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> bookAppointment(Map<String, dynamic> appointmentData) async {
    try {
      // Format appointmentDate as YYYY-MM-DD (not ISO8601 with time)
      String appointmentDateStr = '';
      if (appointmentData['appointmentDate'] != null) {
        if (appointmentData['appointmentDate'] is DateTime) {
          final date = appointmentData['appointmentDate'] as DateTime;
          appointmentDateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        } else if (appointmentData['appointmentDate'] is String) {
          // If already a string, try to parse and format it
          try {
            final date = DateTime.parse(appointmentData['appointmentDate'] as String);
            appointmentDateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          } catch (e) {
            appointmentDateStr = appointmentData['appointmentDate'] as String;
          }
        }
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/book'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'mobileUserID': appointmentData['mobileUserID'] ?? appointmentData['patientID'],
          'quantityRequested': appointmentData['quantityRequested'] ?? 1,
          'appointmentDate': appointmentDateStr.isNotEmpty ? appointmentDateStr : DateTime.now().toString().split(' ')[0],
          'appointmentTime': appointmentData['appointmentTime'] ?? '',
          'location': appointmentData['location'] ?? '',
          'source': appointmentData['source'] ?? 'Mobile',
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return true;
        } else {
          // Throw exception with error message from API
          throw Exception(data['message'] ?? 'Failed to book appointment');
        }
      } else {
        // Try to parse error message from response
        try {
          final data = jsonDecode(response.body);
          throw Exception(data['message'] ?? 'Failed to book appointment');
        } catch (_) {
          throw Exception('Failed to book appointment: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      // Re-throw to preserve error message
      rethrow;
    }
  }

  Future<bool> cancelAppointment(int transfusionID) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/cancel/$transfusionID'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rescheduleAppointment(int transfusionID, DateTime newDate, String newTime) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments/reschedule/$transfusionID'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'appointmentDate': newDate.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
          'appointmentTime': newTime,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Donations
  Future<List<Donation>> getDonationHistory(int mobileUserID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/history/$mobileUserID'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['donations'] as List)
            .map((json) => Donation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getDonationStats(int mobileUserID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/stats/$mobileUserID'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Profile
  Future<MobileUser> getUserProfile(int mobileUserID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$mobileUserID'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return MobileUser.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateProfile(int mobileUserID, Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/update/$mobileUserID'),
        headers: await _getHeaders(),
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Notifications
  Future<List<Notification>> getNotifications(int mobileUserID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$mobileUserID'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['notifications'] as List)
            .map((json) => Notification.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> markNotificationAsRead(int notificationID) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/read/$notificationID'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAllNotifications(int mobileUserID) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/clear/$mobileUserID'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

