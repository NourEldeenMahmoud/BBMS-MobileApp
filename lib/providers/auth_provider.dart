import 'package:flutter/foundation.dart';
import '../models/mobile_user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  MobileUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  MobileUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(phoneNumber, password);

      if (response['success'] == true) {
        _currentUser = MobileUser.fromJson(response['user']);
        await _storageService.saveUser(_currentUser!);
        await _storageService.saveToken(response['token']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(userData);
      if (response['success'] == true) {
        // Auto-login after successful registration
        if (response['user'] != null) {
          _currentUser = MobileUser.fromJson(response['user']);
          await _storageService.saveUser(_currentUser!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _error = null;
    await _storageService.clearAll();
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final user = await _storageService.getUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

