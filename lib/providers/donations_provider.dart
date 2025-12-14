import 'package:flutter/foundation.dart';
import '../models/donation.dart';
import '../services/api_service.dart';

class DonationsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Donation> _donations = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<Donation> get donations => _donations;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalDonations => _donations.length;
  double get totalVolume => _donations.fold<double>(0, (sum, d) => sum + d.bloodVolume);
  Donation? get lastDonation => _donations.isNotEmpty ? _donations.first : null;

  Future<void> loadDonationHistory(int mobileUserID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donations = await _apiService.getDonationHistory(mobileUserID);
      // Sort by date descending (newest first)
      _donations.sort((a, b) => b.donationDate.compareTo(a.donationDate));
    } catch (e) {
      _error = 'Failed to load donation history: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDonationStats(int mobileUserID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _apiService.getDonationStats(mobileUserID);
    } catch (e) {
      _error = 'Failed to load donation stats: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll(int mobileUserID) async {
    await Future.wait([
      loadDonationHistory(mobileUserID),
      loadDonationStats(mobileUserID),
    ]);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

