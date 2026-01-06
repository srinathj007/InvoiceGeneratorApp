import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
import '../core/theme.dart';
import 'create_invoice_screen.dart';
import 'login_screen.dart';
import '../services/supabase_service.dart';
import '../services/profile_service.dart';
import '../services/invoice_service.dart';
import '../models/invoice.dart';
import 'invoice_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  final _invoiceService = InvoiceService();
  
  String _proprietorName = 'Business Owner';
  String _businessName = 'My Business';
  bool _isLoading = true;
  List<Invoice> _recentInvoices = [];
  bool _isAnnualRevenue = false;
  double _totalRevenue = 0.0;
  bool _isRevenueLoading = false;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileService.getProfile();
      final invoices = await _invoiceService.getRecentInvoices();
      
      if (mounted) {
        setState(() {
          if (profile != null) {
            _proprietorName = profile.proprietor;
            _businessName = profile.businessName;
            _logoUrl = profile.logoUrl;
          }
          _recentInvoices = invoices.take(10).toList();
          _isLoading = false;
        });
        _fetchRevenue(); // Fetch revenue independently
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRevenue() async {
    setState(() => _isRevenueLoading = true);
    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = DateTime(now.year, now.month, now.day);

      if (_isAnnualRevenue) {
        startDate = DateTime(now.year, 1, 1);
      } else {
        startDate = DateTime(now.year, now.month, 1);
      }

      final revenue = await _invoiceService.getTotalRevenue(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() {
          _totalRevenue = revenue;
          _isRevenueLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isRevenueLoading = false);
    }
  }

  Future<void> _handleLogout() async {
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
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
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
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                   Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_logoUrl!, fit: BoxFit.contain),
                          )
                        : Icon(Icons.business_outlined, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.welcomeBack},',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _businessName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: Icon(Icons.logout, color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
            
                    // HERO SECTION (Refactored Premium UI)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Abstract shapes for "creativity"
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isAnnualRevenue ? l10n.annualEarnings : l10n.monthlyEarnings,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 3,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                            // Annual/Monthly Toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black12.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _buildRevenueToggle('Month', !_isAnnualRevenue),
                                  _buildRevenueToggle('Year', _isAnnualRevenue),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _isRevenueLoading 
                              ? const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : Text(
                                  // Use ?? 0.0 as a safeguard
                                  NumberFormat('#,##,###.00').format(_totalRevenue),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Small trend indicator
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.greenAccent[100], size: 16),
                            const SizedBox(width: 6),
                            Text(
                              l10n.realTimeData,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // QUICK ACTIONS (Fixed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      l10n.newInvoice,
                      Icons.add,
                      theme.colorScheme.primary,
                      () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
                        );
                        if (result == true) {
                          _loadData();
                          _fetchRevenue();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      l10n.clients,
                      Icons.people_alt_outlined,
                      Colors.purple,
                      () {
                        AppTheme.showToast(context, 'Client Management Coming Soon');
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // RECENT ACTIVITY HEADER (Fixed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentActivity,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),

            // SCROLLABLE LIST (Expanded)
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _recentInvoices.isEmpty 
                  ? Center(child: Text(l10n.noRecentInvoices, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _recentInvoices.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 60,
                        endIndent: 16,
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                      itemBuilder: (context, index) {
                        return _buildRecentInvoiceItem(context, _recentInvoices[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRevenueToggle(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAnnualRevenue = label == 'Year';
        });
        _fetchRevenue();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoiceItem(BuildContext context, Invoice invoice) {
    final theme = Theme.of(context);
    final amount =  invoice.totalAmount;
    final date = invoice.date;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.receipt_outlined, color: theme.colorScheme.primary),
      ),
      title: Text(
        invoice.invoiceNumber,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        invoice.customerName,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            DateFormat('MMM dd').format(date),
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      onTap: () => _showInvoiceDetailsDialog(invoice),
    );
  }

  Future<void> _showInvoiceDetailsDialog(Invoice invoice) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final isTablet = width >= 600 && width < 1200;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: isTablet ? width * 0.7 : null,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        l10n.invoiceDetails,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow(theme, 'Invoice No', invoice.invoiceNumber),
                  _buildDetailRow(theme, 'Customer', invoice.customerName),
                  _buildDetailRow(theme, 'Date', DateFormat('dd MMM yyyy').format(invoice.date)),
                  _buildDetailRow(theme, 'Amount', '₹${invoice.totalAmount.toStringAsFixed(2)}', isBold: true),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmDelete(invoice);
                          },
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: Text(l10n.delete),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog first
                            _navigateToEdit(invoice);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: Text(l10n.edit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: invoice))
                        ).then((_) => _loadData());
                      }, 
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(l10n.viewAndPrint),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value, 
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? theme.colorScheme.primary : theme.colorScheme.onSurface
            )
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Invoice invoice) async {
    final l10n = AppLocalizations.of(context)!;
    if (invoice.id == null) {
      if (mounted) AppTheme.showToast(context, 'Cannot delete: Invoice ID missing', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final isTablet = width >= 600 && width < 1200;
        
        return AlertDialog(
          title: Text(l10n.deleteInvoice),
          content: Container(
            width: isTablet ? width * 0.7 : null,
            child: Text(l10n.deleteConfirmation(invoice.invoiceNumber)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _invoiceService.deleteInvoice(invoice.id!);
        if (mounted) {
          AppTheme.showToast(context, l10n.deleteSuccess);
          // Add small delay to allow database to propagate the delete
          await Future.delayed(const Duration(milliseconds: 300));
          await _loadData(); // Refresh list
        }
      } catch (e) {
        if (mounted) AppTheme.showToast(context, 'Error deleting: $e', isError: true);
      }
    }
  }

  Future<void> _navigateToEdit(Invoice invoice) async {
    if (invoice.id == null) {
      if (mounted) AppTheme.showToast(context, 'Cannot edit: Invoice ID missing', isError: true);
      return;
    }
    
    // Show loading indicator while fetching full invoice
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }
    
    try {
      final fullInvoice = await _invoiceService.getInvoiceById(invoice.id!);
      
      if (mounted) Navigator.pop(context); // Close loading dialog
      
      if (fullInvoice == null) {
        if (mounted) AppTheme.showToast(context, 'Error loading invoice details', isError: true);
        return;
      }
      
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateInvoiceScreen(invoiceToEdit: fullInvoice)),
        );
        
        if (result == true) {
          // Add small delay to allow database to propagate the update
          await Future.delayed(const Duration(milliseconds: 300));
          await _loadData(); // Refresh list
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        AppTheme.showToast(context, 'Error: $e', isError: true);
      }
    }
  }
}
