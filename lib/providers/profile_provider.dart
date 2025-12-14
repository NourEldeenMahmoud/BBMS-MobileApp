import 'package:flutter/foundation.dart';
import '../models/mobile_user.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  MobileUser? _user;
  bool _isLoading = false;
  String? _error;

  MobileUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(int mobileUserID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.getUserProfile(mobileUserID);
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(int mobileUserID, Map<String, dynamic> profileData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.updateProfile(mobileUserID, profileData);
      if (success) {
        // Reload profile
        await loadProfile(mobileUserID);
      } else {
        _error = 'Failed to update profile';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error updating profile: ${e.toString()}';
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

