import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'view_invoices_screen.dart';
import 'profile_screen.dart';
import '../services/profile_service.dart';
import '../models/business_profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _businessName = 'Business';
  final ProfileService _profileService = ProfileService();

  final List<Widget> _mobileScreens = [
    const HomeScreen(),
    const DashboardScreen(),
    const ViewInvoicesScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _tabletScreens = [
    const DashboardScreen(),
    const ViewInvoicesScreen(),
    const ProfileScreen(),
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Scaffold(
        body: _mobileScreens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    } else {
      // Tablet/Desktop - Top Navigation
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Text(
                _businessName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              _buildNavButton('Dashboard', 0, Icons.dashboard_outlined),
              const SizedBox(width: 8),
              _buildNavButton('Invoices', 1, Icons.receipt_long_outlined),
              const SizedBox(width: 8),
              _buildNavButton('Settings', 2, Icons.settings_outlined),
            ],
          ),
        ),
        body: _tabletScreens[_selectedIndex],
      );
    }
  }

  Widget _buildNavButton(String label, int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return TextButton.icon(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.black54,
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryColor.withAlpha(20) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
