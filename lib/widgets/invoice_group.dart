import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';

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

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceTile({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0); // No decimals in ref? Ref shows decimals for some. 

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light Blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF1976D2), // Blue
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.customerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '# ${invoice.invoiceNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  // Custom Field (Vehicle Number)
                  if (invoice.vehicleNumber?.isNotEmpty == true) ...[
                     const SizedBox(height: 2),
                     Text(
                        invoice.vehicleNumber!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                     ),
                  ],
                ],
              ),
            ),

            // Trailing
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      currencyFormat.format(invoice.totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32), // Greenish
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
                // Status dot (mocked as visual sugar from ref "O >")
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 26), // Align under checks
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Placeholder
                      shape: BoxShape.circle,
                       border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
