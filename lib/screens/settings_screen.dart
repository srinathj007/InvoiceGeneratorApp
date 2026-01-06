import 'package:flutter/material.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../services/supabase_service.dart';
import '../services/profile_service.dart';
import '../models/business_profile.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../core/theme.dart';
import '../main.dart'; // Access localeProvider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileService = ProfileService();
  BusinessProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final isTablet = width >= 600 && width < 1200;

        return AlertDialog(
          title: Text(l10n.logout),
          content: Container(
            width: isTablet ? width * 0.7 : null,
            child: Text(l10n.logoutConfirmation),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final authService = AuthService();
      try {
        await authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          AppTheme.showToast(context, 'Error logging out', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                   // 1. Logo
                   Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _profile?.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(_profile!.logoUrl!, fit: BoxFit.contain),
                        )
                      : Icon(Icons.business_outlined, size: 40, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 32),

                  // 2. Business Name
                  Text(
                    _profile?.businessName ?? 'Business Name',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // 3. Proprietor Name
                  if (_profile?.proprietor.isNotEmpty == true) ...[
                    Text(
                      'Prop: ${_profile!.proprietor}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Language Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.language, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(l10n.language, style: theme.textTheme.bodyMedium),
                        const Spacer(),
                        DropdownButton<Locale>(
                          value: localeProvider.locale,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: Locale('en'), child: Text('English')),
                            DropdownMenuItem(value: Locale('te'), child: Text('Telugu')),
                            DropdownMenuItem(value: Locale('hi'), child: Text('Hindi')),
                          ], 
                          onChanged: (val) {
                            if (val != null) {
                              localeProvider.setLocale(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Phone Numbers & Address (Info Section)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        if (_profile?.phoneNumbers.isNotEmpty == true)
                          _buildInfoRow(context, Icons.phone_outlined, _profile!.phoneNumbers),
                        if (_profile?.phoneNumbers.isNotEmpty == true && _profile?.address.isNotEmpty == true)
                          Divider(height: 24, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                        if (_profile?.address.isNotEmpty == true)
                          _buildInfoRow(context, Icons.location_on_outlined, _profile!.address),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 5. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            ).then((_) => _loadProfile());
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: theme.colorScheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                          child: Text(l10n.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _handleLogout,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    'App Version 1.0.0',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
