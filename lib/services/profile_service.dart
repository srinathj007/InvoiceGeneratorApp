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
}
