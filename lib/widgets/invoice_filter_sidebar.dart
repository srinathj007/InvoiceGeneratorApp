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
  DateTime? _startDate;
  DateTime? _endDate;

  void _apply() {
    widget.onApply({
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  void _setDatePreset(String preset) {
    final now = DateTime.now();
    setState(() {
      switch (preset) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'this_month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'last_month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case 'this_year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
      }
    });
    _apply();
  }

  void _reset() {
    setState(() {
      _startDate = null;
      _endDate = null;
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATE RANGE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPresetButton('This Month', 'this_month'),
                  const SizedBox(height: 8),
                  _buildPresetButton('Last Month', 'last_month'),
                  const SizedBox(height: 8),
                  _buildPresetButton('This Year', 'this_year'),
                  const SizedBox(height: 24),
                  
                  Text(
                    'CUSTOM RANGE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(context, 'From Date', _startDate, (d) => setState(() => _startDate = d)),
                  const SizedBox(height: 12),
                  _buildDatePicker(context, 'To Date', _endDate, (d) => setState(() => _endDate = d)),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Apply'),
                  ),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null ? DateFormat('dd MMM yyyy').format(date) : hint,
                style: TextStyle(
                  fontSize: 14,
                  color: date != null 
                    ? Theme.of(context).colorScheme.onSurface 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, String preset) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _setDatePreset(preset),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label),
      ),
    );
  }
}
