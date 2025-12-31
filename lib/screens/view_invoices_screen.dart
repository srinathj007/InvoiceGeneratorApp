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

  // Filters & Search
  Map<String, dynamic> _currentFilters = {};
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
        searchQuery: _searchQuery,
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
    // Only pop if the drawer is open (prevents closing screen on search/sort popup)
    if (_scaffoldKey.currentState?.isEndDrawerOpen == true) {
      Navigator.pop(context);
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    // Sidebar for Tablet/Desktop
    Widget? sidebar = !isMobile 
      ? SizedBox(
          width: 320,
          child: Material(
            elevation: 1,
            child: InvoiceFilterSidebar(onApply: _applyFilters, onReset: _resetFilters),
          ),
        )
      : null;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search customer, invoice, details...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _fetchInvoices(refresh: true);
                },
              )
            : const Text('Invoices'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = null;
                  _searchController.clear();
                  _fetchInvoices(refresh: true);
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              final isAsc = value.endsWith('_asc');
              final field = value.replaceFirst('_asc', '').replaceFirst('_desc', '');
              _applyFilters({
                ..._currentFilters,
                'sortBy': field,
                'isAscending': isAsc,
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'created_at_desc', child: Text('Newest First')),
              const PopupMenuItem(value: 'created_at_asc', child: Text('Oldest First')),
              const PopupMenuItem(value: 'total_amount_desc', child: Text('Highest Amount')),
              const PopupMenuItem(value: 'total_amount_asc', child: Text('Lowest Amount')),
              const PopupMenuItem(value: 'customer_name_asc', child: Text('Customer A-Z')),
            ],
          ),
        ],
      ),
      endDrawer: isMobile
          ? Drawer(
              width: 320,
              child: InvoiceFilterSidebar(onApply: _applyFilters, onReset: _resetFilters),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
          ).then((result) {
            if (result == true) _fetchInvoices(refresh: true);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
      body: Row(
        children: [
          if (sidebar != null) ...[
            sidebar,
            const VerticalDivider(width: 1),
          ],
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_invoices.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Create a new invoice to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchInvoices(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _invoices.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => Divider(
          height: 1, 
          indent: 20, 
          endIndent: 20, 
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
        itemBuilder: (context, index) {
          if (index == _invoices.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          final invoice = _invoices[index];
          return _buildInvoiceListItem(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceListItem(Invoice invoice) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice: invoice)),
        );
        if (result == true) {
          // Invoice was deleted or updated, refresh the list
          _fetchInvoices(refresh: true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.description_outlined, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '₹${invoice.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          invoice.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(invoice.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (invoice.vehicleNumber?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.label_outline, size: 14, color: theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          invoice.vehicleNumber!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
