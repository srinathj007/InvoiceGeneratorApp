import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // For grouping
import '../core/theme.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import '../widgets/invoice_group.dart'; // New Group Widget
import 'create_invoice_screen.dart'; 
import 'invoice_detail_screen.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';

class ViewInvoicesScreen extends StatefulWidget {
  const ViewInvoicesScreen({super.key});

  @override
  State<ViewInvoicesScreen> createState() => _ViewInvoicesScreenState();
}

class _ViewInvoicesScreenState extends State<ViewInvoicesScreen> {
  Timer? _debounce;
  final InvoiceService _invoiceService = InvoiceService();
  final ScrollController _scrollController = ScrollController();
  
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  
  // State for Grouped List
  Map<DateTime, List<Invoice>> _groupedInvoices = {};
  List<DateTime> _sortedDates = [];

  // Filters & Search (Standard AppBar)
  Map<String, dynamic> _currentFilters = {};
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Sort Options Map (Value -> Label Key for localization)
  Map<String, String> _sortOptions = {
    'created_at_desc': 'newestFirst', 
    'created_at_asc': 'oldestFirst',
    'total_amount_desc': 'highestAmount',
    'total_amount_asc': 'lowestAmount',
    'customer_name_asc': 'customerAZ',
  };
  String _currentSort = 'created_at_desc';

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(_onscroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onscroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchInvoices();
    }
  }

  int _fetchGeneration = 0;

  Future<void> _fetchInvoices({bool refresh = false}) async {
    // If refreshing (search/sort changed), we allow new fetch even if loading
    // If pagination (scrolling), we respect loading lock
    if (!refresh && _isLoading) return;

    final int currentGeneration = ++_fetchGeneration;

    setState(() => _isLoading = true);

    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _invoices = [];
      _groupedInvoices = {};
      _sortedDates = [];
    }

    try {
      final newInvoices = await _invoiceService.getInvoices(
        searchQuery: _searchQuery, 
        sortBy: _currentFilters['sortBy'] ?? 'created_at',
        isAscending: _currentFilters['isAscending'] ?? false,
        page: _currentPage,
        pageSize: _pageSize,
      );

      // Check if this is still the latest request
      if (mounted && currentGeneration == _fetchGeneration) {
        setState(() {
          _invoices.addAll(newInvoices);
          _processingGrouping(); 
          _currentPage++;
          if (newInvoices.length < _pageSize) {
            _hasMore = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && currentGeneration == _fetchGeneration) {
         setState(() => _isLoading = false);
      }
    }
  }

  void _processingGrouping() {
    // Manual Grouping to avoid potential package issues or undefined types
    final Map<DateTime, List<Invoice>> groups = {};
    
    for (var invoice in _invoices) {
      final date = DateTime(invoice.date.year, invoice.date.month, invoice.date.day);
      if (groups.containsKey(date)) {
        groups[date]!.add(invoice);
      } else {
        groups[date] = [invoice];
      }
    }
    
    _groupedInvoices = groups;
    // Sort dates descending (Newest first)
    final sortedKeys = groups.keys.toList();
    sortedKeys.sort((a, b) => b.compareTo(a));
    _sortedDates = sortedKeys;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Helper to get localized label
    String getSortLabel(String key) {
       switch(key) {
         case 'newestFirst': return l10n.newestFirst;
         case 'oldestFirst': return l10n.oldestFirst;
         case 'highestAmount': return l10n.highestAmount;
         case 'lowestAmount': return l10n.lowestAmount;
         case 'customerAZ': return l10n.customerAZ;
         default: return '';
       }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Restore premium grey
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent, 
        backgroundColor: const Color(0xFFF5F7FA), // Match Scaffold
        automaticallyImplyLeading: false, // Ensure no automatic back button either if user wants it gone
        title: Text(l10n.invoices, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort), 
            onPressed: () => _showSortOptions(context, getSortLabel),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
         child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
              ).then((result) {
                if (result == true) _fetchInvoices(refresh: true);
              });
            },
            backgroundColor: const Color(0xFFE3F2FD),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            label: Text(
              l10n.newInvoice, 
              style: TextStyle(
                color: theme.colorScheme.primary, 
                fontWeight: FontWeight.bold,
                fontSize: 16
              )
            ),
          ),
        ),
      ),
      body: Column(
        children: [
           Container(
             color: const Color(0xFFF5F7FA), // Match Background
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
             child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white, // Search Bar is White
                  borderRadius: BorderRadius.circular(50), // Pill Shape
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    filled: false, 
                    fillColor: Colors.transparent,
                    hintText: l10n.searchPlaceholder,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), // Let TextAlignVertical handle vertical centering
                  ),
                  onChanged: (value) {
                     if (_debounce?.isActive ?? false) _debounce!.cancel();
                     _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() => _searchQuery = value);
                        _fetchInvoices(refresh: true);
                     });
                  },
                  onSubmitted: (value) {
                     if (_debounce?.isActive ?? false) _debounce!.cancel();
                     setState(() => _searchQuery = value);
                     _fetchInvoices(refresh: true);
                  },
                ),
              ),
           ),
           Expanded(child: _buildGroupedList(l10n)),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, String Function(String) getLabel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Padding(
                 padding: const EdgeInsets.only(bottom: 10),
                 child: Text(
                    'Sort By', // Needs l10n
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                 ),
               ),
              ...(_sortOptions.entries).map((entry) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _currentSort == entry.key ? Theme.of(context).colorScheme.primaryContainer : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sort, 
                    size: 20, 
                    color: _currentSort == entry.key ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                ),
                title: Text(getLabel(entry.value)),
                trailing: _currentSort == entry.key 
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) 
                    : null,
                onTap: () {
                  _onSortSelected(entry.key);
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  void _onSortSelected(String sortValue) {
      final isAsc = sortValue.endsWith('_asc');
      final field = sortValue.replaceFirst('_asc', '').replaceFirst('_desc', '');
      
      setState(() {
        _currentSort = sortValue;
        _currentFilters = {
          'sortBy': field,
          'isAscending': isAsc,
        };
      });
      _fetchInvoices(refresh: true);
  }

  Widget _buildGroupedList(AppLocalizations l10n) {
    // Paranoid check for initial state
    if (_invoices == null || _sortedDates == null || _groupedInvoices == null) {
       return const Center(child: CircularProgressIndicator());
    }

    if (_invoices.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(l10n.noInvoicesFound, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchInvoices(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100), // Space for FAB
        itemCount: (_sortedDates.length) + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _sortedDates.length) {
             if (_hasMore) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
             } else {
                return const SizedBox.shrink(); // Should not happen based on count
             }
          }
          
          final date = _sortedDates[index];
          final dayInvoices = _groupedInvoices[date];
          
          if (dayInvoices == null) return const SizedBox.shrink();

          return InvoiceGroup(
            date: date,
            invoices: dayInvoices,
            onInvoiceTap: (invoice) async {
               final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice: invoice)),
               );
               if (result == true) _fetchInvoices(refresh: true);
            },
          );
        },
      ),
    );
  }
}
