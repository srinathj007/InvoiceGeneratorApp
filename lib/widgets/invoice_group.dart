import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import 'invoice_tile.dart';

class InvoiceGroup extends StatelessWidget {
  final DateTime date;
  final List<Invoice> invoices;
  final Function(Invoice) onInvoiceTap;

  const InvoiceGroup({
    super.key,
    required this.date,
    required this.invoices,
    required this.onInvoiceTap,
  });

  String _getDateHeader() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groupDate = DateTime(date.year, date.month, date.day);

    if (groupDate == today) {
      return 'Today';
    } else if (groupDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Paranoid check
    // ignore: unnecessary_null_comparison
    if (invoices == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            _getDateHeader(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(invoices.length, (index) {
              final invoice = invoices[index];
              return Column(
                children: [
                  InvoiceTile(invoice: invoice, onTap: () => onInvoiceTap(invoice)),
                  if (index < invoices.length - 1)
                    Divider(
                      height: 1,
                      indent: 70, // Align with text start
                      endIndent: 20,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}


