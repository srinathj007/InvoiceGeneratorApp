import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';

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
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0); 

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
