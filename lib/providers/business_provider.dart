import 'package:flutter/material.dart';
import '../models/business_profile.dart';
import '../services/profile_service.dart';

class BusinessProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  BusinessProfile? _activeProfile;
  bool _isLoading = true;

  BusinessProfile? get activeProfile => _activeProfile;
  bool get isLoading => _isLoading;

  BusinessProvider() {
    loadActiveProfile();
  }

  Future<void> loadActiveProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _activeProfile = await _profileService.getProfile();
    } catch (e) {
      print('Error loading active profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setActiveProfile(String profileId) async {
    await _profileService.setActiveProfileId(profileId);
    await loadActiveProfile();
  }
  
  // Method to refresh data if something changed in profile but ID is same
  Future<void> refreshProfile() async {
    await loadActiveProfile();
  }
}
