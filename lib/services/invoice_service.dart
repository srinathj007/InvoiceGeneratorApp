import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // 1. Insert Invoice
    final invoiceData = invoice.toJson();
    invoiceData['user_id'] = user.id;

    final invoiceResponse = await _supabase
        .from('invoices')
        .insert(invoiceData)
        .select()
        .single();

    final String invoiceId = invoiceResponse['id'];

    // 2. Insert Items
    final List<Map<String, dynamic>> itemsData = items.map((item) {
      final data = item.toJson();
      data['invoice_id'] = invoiceId;
      return data;
    }).toList();

    await _supabase.from('invoice_items').insert(itemsData);
  }

  Future<void> updateInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    if (invoice.id == null) throw Exception('Invoice ID required for update');

    // 1. Update Invoice
    final invoiceData = invoice.toJson();
    invoiceData['user_id'] = user.id;
    // Remove ID from data to avoid update error if DB handles it, though usually fine.
    // However, we are targeting by ID, so we don't need to set it in body if we use .eq
    
    await _supabase
        .from('invoices')
        .update(invoiceData)
        .eq('id', invoice.id!);

    // 2. Update Items (Delete all and re-insert)
    // First, delete existing items
    await _supabase
        .from('invoice_items')
        .delete()
        .eq('invoice_id', invoice.id!);

    // Then insert new items
    final List<Map<String, dynamic>> itemsData = items.map((item) {
      final data = item.toJson();
      data['invoice_id'] = invoice.id;
      // Remove item ID if it exists to ensure new IDs are generated or handled by DB
      data.remove('id'); 
      return data;
    }).toList();

    if (itemsData.isNotEmpty) {
      await _supabase.from('invoice_items').insert(itemsData);
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Items should be deleted via cascade if configured in DB, 
    // but to be safe/explicit we can delete them or rely on DB constraint.
    // Assuming cascade delete is set up on foreign key. If not, we should delete items first.
    // Let's assume standard cascade or delete items first.
    
    await _supabase
        .from('invoices')
        .delete()
        .eq('id', invoiceId)
        .eq('user_id', user.id); // Security check
  }

  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select('*, invoice_items(*)') // Join items
          .eq('id', id)
          .single();
      
      final itemsJson = (response['invoice_items'] as List);
      final items = itemsJson.map((i) => InvoiceItem.fromJson(i)).toList();
      
      return Invoice.fromJson(response, items);
    } catch (e) {
      return null;
    }
  }

  Future<List<Invoice>> getRecentInvoices() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('invoices')
        .select('*, invoice_items(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List).map((json) {
      final itemsJson = (json['invoice_items'] as List?) ?? [];
      final items = itemsJson.map((i) => InvoiceItem.fromJson(i)).toList();
      return Invoice.fromJson(json, items);
    }).toList();
  }

  Future<List<Invoice>> getInvoices({
    String? customerName,
    String? phoneNumber,
    String? vehicleNumber,
    String? invoiceNumber,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'created_at',
    bool isAscending = false,
    int page = 0,
    int pageSize = 10,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    dynamic query = _supabase
        .from('invoices')
        .select()
        .eq('user_id', user.id);

    // Apply Filters
    if (customerName != null && customerName.isNotEmpty) {
      query = query.ilike('customer_name', '%$customerName%');
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      query = query.ilike('customer_phone', '%$phoneNumber%');
    }
    if (vehicleNumber != null && vehicleNumber.isNotEmpty) {
      query = query.ilike('vehicle_number', '%$vehicleNumber%');
    }
    if (invoiceNumber != null && invoiceNumber.isNotEmpty) {
      query = query.ilike('invoice_number', '%$invoiceNumber%');
    }
    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String());
    }
    if (endDate != null) {
      final nextDay = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
      query = query.lt('date', nextDay.toIso8601String());
    }

    // Apply Sorting
    query = query.order(sortBy, ascending: isAscending);

    // Apply Pagination
    final start = page * pageSize;
    final end = start + pageSize - 1;
    query = query.range(start, end);

    final response = await query.select('*, invoice_items(*)');
    return (response as List).map((json) {
      final itemsJson = (json['invoice_items'] as List?) ?? [];
      final items = itemsJson.map((i) => InvoiceItem.fromJson(i)).toList();
      return Invoice.fromJson(json, items);
    }).toList();
  }

  Future<double> getTotalRevenue({DateTime? startDate, DateTime? endDate}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    var query = _supabase
        .from('invoices')
        .select('total_amount')
        .eq('user_id', user.id);

    if (startDate != null) {
      query = query.gte('invoice_date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('invoice_date', endDate.toIso8601String().split('T')[0]);
    }

    final response = await query;
    final List data = (response as List?) ?? [];
    
    return data.fold<double>(0.0, (sum, item) {
      final val = item['total_amount'];
      if (val == null) return sum;
      return sum + (val as num).toDouble();
    });
  }
}
