import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _activeProfileKey = 'active_profile_id';

  /// Fetch all profiles belonging to the current user
  Future<List<BusinessProfile>> getProfiles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id);

      final list = response as List;
      return list.map((e) => BusinessProfile.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get the currently active business profile
  /// Returns the one matching the stored ID, or the first one if none selected or found.
  Future<BusinessProfile?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final profiles = await getProfiles();
    if (profiles.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeProfileKey);

    if (activeId != null) {
      try {
        return profiles.firstWhere((p) => p.id == activeId);
      } catch (e) {
        // Active ID not found in list (maybe deleted), fallback to first
        await setActiveProfileId(profiles.first.id!); 
        return profiles.first;
      }
    }

    // No active ID stored, default to first and store it
    if (profiles.first.id != null) {
      await setActiveProfileId(profiles.first.id!);
    }
    return profiles.first;
  }

  Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, id);
  }

  /// Save or Update a profile
  Future<void> saveProfile(BusinessProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = profile.toJson();
    data['user_id'] = user.id;

    // Use select() to return the inserted row so we can get the ID
    final response = await _supabase.from('profiles').upsert(data).select().single();
    
    // If this was a new profile (no ID initially), or we just want to ensure it's active
    // You might want to auto-switch to the new business, or keep the current one.
    // For now, if we are creating a NEW one, maybe switch to it?
    // Let's decide: if it didn't have an ID, it's new.
    if (profile.id == null) {
       final newId = response['id'];
       if (newId != null) {
          await setActiveProfileId(newId.toString());
       }
    }
  }

  Future<String?> uploadImage(String fileName, Uint8List fileBytes) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final path = '${user.id}/$fileName';
    
    try {
      await _supabase.storage.from('assets').uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final String publicUrl = _supabase.storage.from('assets').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (e is StorageException) {
      }
      return null;
    }
  }
}
