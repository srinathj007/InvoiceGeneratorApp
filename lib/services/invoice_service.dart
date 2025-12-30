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

  Future<List<Invoice>> getRecentInvoices() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('invoices')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List).map((json) => Invoice.fromJson(json)).toList();
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

    final response = await query;
    return (response as List).map((json) => Invoice.fromJson(json)).toList();
  }
}
