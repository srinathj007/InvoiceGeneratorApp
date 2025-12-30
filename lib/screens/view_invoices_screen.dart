import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/invoice_filter_sidebar.dart';
import 'create_invoice_screen.dart'; // For navigation to create
import 'invoice_detail_screen.dart';

class ViewInvoicesScreen extends StatefulWidget {
  const ViewInvoicesScreen({super.key});

  @override
  State<ViewInvoicesScreen> createState() => _ViewInvoicesScreenState();
}

class _ViewInvoicesScreenState extends State<ViewInvoicesScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Invoice> _invoices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  // Filters
  Map<String, dynamic> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchInvoices();
    }
  }

  Future<void> _fetchInvoices({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _invoices.clear();
    }

    try {
      final newInvoices = await _invoiceService.getInvoices(
        customerName: _currentFilters['customerName'],
        phoneNumber: _currentFilters['phoneNumber'],
        vehicleNumber: _currentFilters['vehicleNumber'],
        invoiceNumber: _currentFilters['invoiceNumber'],
        startDate: _currentFilters['startDate'],
        endDate: _currentFilters['endDate'],
        sortBy: _currentFilters['sortBy'] ?? 'created_at',
        isAscending: _currentFilters['isAscending'] ?? false,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _invoices.addAll(newInvoices);
          _currentPage++;
          if (newInvoices.length < _pageSize) {
            _hasMore = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppTheme.showToast(context, 'Error loading invoices: $e', isError: true);
      }
    }
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
    _fetchInvoices(refresh: true);
    if (ResponsiveLayout.isMobile(context)) {
      Navigator.pop(context); // Close drawer on mobile
    }
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = {};
    });
    _fetchInvoices(refresh: true);
    // Don't close drawer on reset, let user modify
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Invoices', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (ResponsiveLayout.isMobile(context))
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
        ],
      ),
      endDrawer: ResponsiveLayout.isMobile(context) 
        ? Drawer(
            width: 300,
            child: SafeArea(
              child: InvoiceFilterSidebar(onApply: _applyFilters, onReset: _resetFilters)
            )
          ) 
        : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
          ).then((_) => _fetchInvoices(refresh: true)); // Refresh on return
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
      body: ResponsiveLayout(
        mobile: _buildList(),
        tablet: Row(
          children: [
            // Persistent Sidebar on Tablet/Desktop
            SizedBox(
              width: 320,
              child: InvoiceFilterSidebar(onApply: _applyFilters, onReset: _resetFilters),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_invoices.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No invoices found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchInvoices(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _invoices.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _invoices.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          final invoice = _invoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice: invoice)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        '₹${invoice.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Customer Name + Phone
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  invoice.customerName,
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (invoice.customerPhone != null && invoice.customerPhone!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: Colors.black54),
                                const SizedBox(width: 8),
                                Text(
                                  invoice.customerPhone!,
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Column 2: Vehicle Number + Date
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (invoice.vehicleNumber != null && invoice.vehicleNumber!.isNotEmpty) ...[
                             Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.directions_car_outlined, size: 16, color: Colors.black54),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    invoice.vehicleNumber!,
                                    style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                             const SizedBox(height: 6),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(invoice.date),
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
