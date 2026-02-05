import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'view_invoices_screen.dart';
import 'settings_screen.dart';
import '../services/profile_service.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';

import 'switch_business_screen.dart';
import 'create_invoice_screen.dart';
import '../main.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _businessName = 'Business';
  final ProfileService _profileService = ProfileService();

  // Screens corresponding to indices:
  // 0: Dashboard
  // 1: Invoices
  // 2: (+) Action - Placeholder, handled separately
  // 3: Switch Business
  // 4: Settings
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ViewInvoicesScreen(),
    const SizedBox.shrink(), // Placeholder for (+)
    const SwitchBusinessScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinessName();
    businessProvider.addListener(_onBusinessChanged);
  }

  void _onBusinessChanged() {
    if (mounted) {
      _loadBusinessName();
    }
  }

  @override
  void dispose() {
    businessProvider.removeListener(_onBusinessChanged);
    super.dispose();
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
    if (index == 2) {
      // Handle (+) Tap directly
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
      );
      return; 
    }
    
    if (index == 3) {
      // Handle Switch Business - Show as Bottom Sheet Modal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const SwitchBusinessScreen(),
      );
      return;
    }
    
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
    
    // Custom Cyan/Blue color for the button gradient to match reference
    final gradientColors = [
      colorScheme.primary, 
      colorScheme.secondary, 
    ];

    return Scaffold(
      extendBody: true, // Allows the FAB to float nicel relative to the notch
      body: _screens[_selectedIndex],
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 18), // Moved down further
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(2), // Index 2 is Add/Create
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: colorScheme.surface,
        elevation: 10,
        padding: EdgeInsets.zero,
        height: 72, // Slightly taller to accommodate labels
        child: Row(
          children: [
            // Left Side Group - Centered
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    index: 0,
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: l10n.dashboard,
                  ),
                  _buildNavItem(
                    context,
                    index: 1,
                    icon: Icons.description_outlined, 
                    activeIcon: Icons.description_rounded,
                    label: l10n.invoices, // Mapped to "Bills" concept
                  ),
                ],
              ),
            ),
            
            // Spacer for FAB - Wider to ensure no overlap and perfect centering
            const SizedBox(width: 80),
            
            // Right Side Group - Centered
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    index: 3, // Switch Profile
                    icon: Icons.store_outlined,
                    activeIcon: Icons.store_rounded,
                    label: l10n.switchLabel,
                  ),
                  _buildNavItem(
                    context,
                    index: 4, // Settings
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: l10n.settings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;
    
    // For actions like Switch Profile (idx 3), we might not want to show "selected" state 
    // if it's a modal action that doesn't switch the screen persistently?
    // Current logic in _onItemTapped:
    // Index 3 (Switch) -> showBottomSheet. It DOES NOT update _selectedIndex.
    // So isSelected will likely be false for index 3 always. That's fine.
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Removed _NavIcon class as it's no longer used




