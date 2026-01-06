import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'view_invoices_screen.dart';
import 'settings_screen.dart';
import '../services/profile_service.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _businessName = 'Business';
  final ProfileService _profileService = ProfileService();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ViewInvoicesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinessName();
  }

  Future<void> _loadBusinessName() async {
    try {
      final profile = await _profileService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _businessName = profile.businessName;
        });
      }
    } catch (e) {
      // Silently fail, keep default name
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Force bottom nav for both mobile and tablet as requested
    // "move nav to below only on tab mode also"
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description),
            label: l10n.invoices,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }


}
