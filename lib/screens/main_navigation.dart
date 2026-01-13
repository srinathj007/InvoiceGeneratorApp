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
    // UPDATED: Now using dynamic theme colors
    final gradientColors = [
      colorScheme.primary, 
      colorScheme.secondary, 
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent, 
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.grid_view_rounded, color: colorScheme.primary),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.description_rounded, color: colorScheme.primary),
            label: l10n.invoices,
          ),
          // Central Hexagon (+) Button
          NavigationDestination(
             icon: Transform.translate(
               offset: const Offset(0, -10), // Slight lift
               child: Container(
                 width: 58,
                 height: 58,
                 decoration: BoxDecoration(
                   boxShadow: [
                     BoxShadow(
                       color: gradientColors[0].withOpacity(0.4),
                       blurRadius: 10,
                       offset: const Offset(0, 4),
                     ),
                   ],
                 ),
                 child: ClipPath(
                   clipper: HexagonClipper(),
                   child: Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: gradientColors,
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                       ),
                     ),
                     child: const Icon(Icons.add, color: Colors.white, size: 32),
                   ),
                 ),
               ),
             ),
             label: '', 
             tooltip: l10n.newInvoice,
             enabled: true, 
          ),
          NavigationDestination(
            icon: const Icon(Icons.store_outlined, color: Colors.grey), // Icon for Switch Business
            selectedIcon: Icon(Icons.store_rounded, color: colorScheme.primary),
            label: l10n.switchLabel, 
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.settings_rounded, color: colorScheme.primary),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Create a hexagon with slightly rounded corners if possible, but standard is fine for clipper
    // Pointy top/bottom or flat top/bottom? Reference image has flat side up? 
    // Wait, ref image has POINTY top/bottom (Vertical Hexagon). 
    // Let's do Pointy Top/Bottom.
    
    // Vertices for Pointy Top Hexagon:
    // (w/2, 0) Top
    // (w, h*0.25) Top Right
    // (w, h*0.75) Bottom Right
    // (w/2, h) Bottom
    // (0, h*0.75) Bottom Left
    // (0, h*0.25) Top Left
    
    path.moveTo(w / 2, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w / 2, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Removed _NavIcon class as it's no longer used




