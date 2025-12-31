import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_profile.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<BusinessProfile?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return BusinessProfile.fromJson(response);
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = profile.toJson();
    data['user_id'] = user.id;

    await _supabase.from('profiles').upsert(data);
  }

  Future<String?> uploadImage(String fileName, Uint8List fileBytes) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('DEBUG: No authenticated user found for upload');
      return null;
    }

    final path = '${user.id}/$fileName';
    print('DEBUG: Attempting to upload to assets bucket at path: $path');
    
    try {
      await _supabase.storage.from('assets').uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final String publicUrl = _supabase.storage.from('assets').getPublicUrl(path);
      print('DEBUG: Upload successful. Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('DEBUG: Storage upload failed: $e');
      if (e is StorageException) {
        print('DEBUG: Storage error message: ${e.message}');
      }
      return null;
    }
  }
}
