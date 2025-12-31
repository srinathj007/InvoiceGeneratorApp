import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(context, _customerNameController, 'Customer Name', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(context, _phoneController, 'Phone Number', Icons.phone_outlined, isPhone: true),
                  const SizedBox(height: 16),
                  _buildTextField(context, _vehicleController, 'Vehicle Number', Icons.directions_car_outlined),
                  const SizedBox(height: 16),
                  _buildTextField(context, _invoiceNumController, 'Invoice Number', Icons.receipt_long_outlined),
                  const SizedBox(height: 24),
                  
                  Text('Date Range', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker(context, 'Start', _startDate, (d) => setState(() => _startDate = d))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDatePicker(context, 'End', _endDate, (d) => setState(() => _endDate = d))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Sort By', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                       DropdownMenuItem(value: 'created_at', child: Text('Created Date')),
                       DropdownMenuItem(value: 'total_amount', child: Text('Total Amount')),
                       DropdownMenuItem(value: 'date', child: Text('Invoice Date')),
                       DropdownMenuItem(value: 'customer_name', child: Text('Customer Name')),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v!),
                  ),
                   const SizedBox(height: 16),
                  DropdownButtonFormField<bool>(
                    value: _isAscending,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                       DropdownMenuItem(value: false, child: Text('Newest First')),
                       DropdownMenuItem(value: true, child: Text('Oldest First')),
                    ],
                    onChanged: (v) => setState(() => _isAscending = v!),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _apply,
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String hint, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? DateFormat('MM/dd').format(date) : hint,
                style: TextStyle(
                  color: date != null 
                    ? Theme.of(context).colorScheme.onSurface 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
