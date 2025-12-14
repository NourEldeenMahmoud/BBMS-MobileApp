import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mobile_user.dart';

class StorageService {
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  Future<void> saveUser(MobileUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<MobileUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        return MobileUser.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyToken);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}

