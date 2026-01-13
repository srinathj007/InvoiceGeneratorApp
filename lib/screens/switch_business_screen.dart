import 'package:flutter/material.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../models/business_profile.dart';
import '../services/profile_service.dart';
import '../screens/main_navigation.dart';
import 'profile_screen.dart';
import '../core/theme.dart';
import '../main.dart';

class SwitchBusinessScreen extends StatefulWidget {
  const SwitchBusinessScreen({super.key});

  @override
  State<SwitchBusinessScreen> createState() => _SwitchBusinessScreenState();
}

class _SwitchBusinessScreenState extends State<SwitchBusinessScreen> {
  final _profileService = ProfileService();
  List<BusinessProfile> _profiles = [];
  String? _activeProfileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final profiles = await _profileService.getProfiles();
      final activeProfile = await _profileService.getProfile();
      
      if (mounted) {
        setState(() {
          _profiles = profiles;
          _activeProfileId = activeProfile?.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _isLoading = false);
        AppTheme.showToast(context, l10n.errorLoadingBusinesses, isError: true);
      }
    }
  }

  Future<void> _switchBusiness(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await businessProvider.setActiveProfile(id);
      if (mounted) {
        AppTheme.showToast(context, l10n.switchedSuccessfully);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showToast(context, l10n.errorSwitchingBusiness, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            minHeight: 300, // Stable minimum height to prevent jumping
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  AppLocalizations.of(context)!.switchBusiness,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              
              // Content with AnimatedSwitcher for smooth transition
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLoading 
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ListView.separated(
                          key: ValueKey(_profiles.length),
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _profiles.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == _profiles.length) {
                              return _buildAddButton(context);
                            }
                            return _buildProfileCard(context, _profiles[index]);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, BusinessProfile profile) {
    final bool isActive = profile.id == _activeProfileId;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return InkWell(
      onTap: () {
        if (profile.id != null && !isActive) {
          _switchBusiness(profile.id!);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? primaryColor : Colors.grey.shade200,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                image: profile.logoUrl != null 
                    ? DecorationImage(image: NetworkImage(profile.logoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: profile.logoUrl == null 
                  ? Icon(Icons.store, color: Colors.grey.shade500) 
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.businessName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.proprietor.isNotEmpty ? profile.proprietor : "Business Account",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Badge / Indicator
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.active,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return InkWell(
      onTap: () async {
        Navigator.pop(context); // Close modal first
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen(isNewBusiness: true)),
        );
        if (result == true) {
          _loadData();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.addNewBusiness,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Icon(Icons.add, color: primaryColor),
          ],
        ),
      ),
    );
  }
}
