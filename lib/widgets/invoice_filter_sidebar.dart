import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class InvoiceFilterSidebar extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApply;
  final VoidCallback onReset;

  const InvoiceFilterSidebar({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<InvoiceFilterSidebar> createState() => _InvoiceFilterSidebarState();
}

class _InvoiceFilterSidebarState extends State<InvoiceFilterSidebar> {
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _invoiceNumController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'created_at';
  bool _isAscending = false;

  void _apply() {
    widget.onApply({
      'customerName': _customerNameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'vehicleNumber': _vehicleController.text.trim(),
      'invoiceNumber': _invoiceNumController.text.trim(),
      'startDate': _startDate,
      'endDate': _endDate,
      'sortBy': _sortBy,
      'isAscending': _isAscending,
    });
  }

  void _reset() {
    setState(() {
      _customerNameController.clear();
      _phoneController.clear();
      _vehicleController.clear();
      _invoiceNumController.clear();
      _startDate = null;
      _endDate = null;
      _sortBy = 'created_at';
      _isAscending = false;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(242),
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                onPressed: _reset,
                tooltip: 'Reset Filters',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(controller: _customerNameController, label: 'Customer Name', hint: 'Enter customer name', prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _phoneController, label: 'Phone Number', hint: 'Enter phone number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _vehicleController, label: 'Vehicle Number', hint: 'Enter vehicle number', prefixIcon: Icons.directions_car_outlined),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _invoiceNumController, label: 'Invoice Number', hint: 'Enter invoice number', prefixIcon: Icons.receipt_long_outlined),
                  const SizedBox(height: 16),
                  _buildDatePicker('Start Date', _startDate, (d) => setState(() => _startDate = d)),
                  const SizedBox(height: 16),
                  _buildDatePicker('End Date', _endDate, (d) => setState(() => _endDate = d)),
                  const SizedBox(height: 24),
                  const Text('Sort By:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: AppTheme.inputDecoration(hint: 'Sort By'),
                    items: const [
                       DropdownMenuItem(value: 'created_at', child: Text('Created At')),
                       DropdownMenuItem(value: 'total_amount', child: Text('Total Amount')),
                       DropdownMenuItem(value: 'date', child: Text('Invoice Date')),
                       DropdownMenuItem(value: 'customer_name', child: Text('Customer Name')),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v!),
                  ),
                   const SizedBox(height: 16),
                  const Text('Sort Order:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: _isAscending,
                    decoration: AppTheme.inputDecoration(hint: 'Order'),
                    items: const [
                       DropdownMenuItem(value: false, child: Text('DESC (Newest/Highest)')),
                       DropdownMenuItem(value: true, child: Text('ASC (Oldest/Lowest)')),
                    ],
                    onChanged: (v) => setState(() => _isAscending = v!),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(text: 'Apply Filters', onPressed: _apply),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onSelect(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('MM/dd/yyyy').format(date) : 'mm/dd/yyyy',
                  style: TextStyle(color: date != null ? Colors.black87 : Colors.black45),
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
