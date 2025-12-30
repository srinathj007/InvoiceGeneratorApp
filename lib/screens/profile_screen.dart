import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/business_profile.dart';
import '../services/profile_service.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _proprietorController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  BusinessProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile != null) {
        setState(() {
          _currentProfile = profile;
          _nameController.text = profile.businessName;
          _addressController.text = profile.address;
          _proprietorController.text = profile.proprietor;
          _phoneController.text = profile.phoneNumbers;
        });
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showToast(context, 'Error loading profile', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty) {
      AppTheme.showToast(context, 'Business Name is required', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        AppTheme.showToast(context, 'User session expired', isError: true);
        return;
      }
      final newProfile = BusinessProfile(
        id: _currentProfile?.id,
        userId: userId,
        businessName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        proprietor: _proprietorController.text.trim(),
        phoneNumbers: _phoneController.text.trim(),
        logoUrl: _currentProfile?.logoUrl,
      );

      await _profileService.saveProfile(newProfile);
      if (mounted) {
        AppTheme.showToast(context, 'Profile saved successfully');
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showToast(context, 'Error saving profile', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _animate({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Interval(delay / 2000 > 1.0 ? 0.9 : delay / 2000, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animate(
            delay: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Profile Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _animate(
            delay: 200,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppTheme.premiumShadows,
                      border: Border.all(color: AppTheme.primaryColor.withAlpha(40), width: 2),
                    ),
                    child: const Icon(Icons.business_outlined, size: 40, color: AppTheme.primaryColor),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          _animate(
            delay: 300,
            child: CustomTextField(
              controller: _nameController,
              label: 'Business Name',
              hint: 'e.g. Srinath Motors',
              prefixIcon: Icons.storefront_outlined,
            ),
          ),
          const SizedBox(height: 20),
          _animate(
            delay: 400,
            child: CustomTextField(
              controller: _proprietorController,
              label: 'Proprietor Name',
              hint: 'e.g. Srinath',
              prefixIcon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 20),
          _animate(
            delay: 500,
            child: CustomTextField(
              controller: _phoneController,
              label: 'Contact Numbers',
              hint: 'e.g. 9010123456, 7777123456',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 20),
          _animate(
            delay: 600,
            child: CustomTextField(
              controller: _addressController,
              label: 'Business Address',
              hint: 'Enter full address...',
              prefixIcon: Icons.location_on_outlined,
            ),
          ),
          const SizedBox(height: 40),
          _animate(
            delay: 700,
            child: _isSaving
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : CustomButton(
                    text: 'Save Business Profile',
                    onPressed: _handleSave,
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : ConstrainedCenter(
                maxWidth: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: GlassContainer(
                    child: _buildProfileForm(),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
