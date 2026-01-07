import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM');
    final timeFormat = DateFormat('HH:mm');
    
    // Determine status color
    // This logic mimics the previous functionality but with a badge style
    Color statusColor = Colors.grey;
    String statusText = 'Pending';
    // Simplified status logic for demo (you might have a real status field)
    // Assuming for now we show "Paid" or "Pending" based on some logic or just "Direct" from reference
    statusColor = theme.colorScheme.primary; 
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left: Time/Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeFormat.format(invoice.date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dateFormat.format(invoice.date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        timeFormat.format(invoice.date.add(const Duration(hours: 1))), // Mock end time/duration
                         style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Center: Timeline Visual
                  Column(
                    children: [
                      _buildDot(theme, false),
                      Container(
                        height: 30,
                        width: 2,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.receipt_long, size: 16, color: theme.colorScheme.primary), // Icon representing flight/invoice
                      ),
                      Container(
                        height: 30,
                        width: 2,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      _buildDot(theme, true),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // Right: Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.customerName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Customer',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          invoice.vehicleNumber?.isNotEmpty == true ? invoice.vehicleNumber! : 'N/A', 
                          style: theme.textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                         'Vehicle No',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                   // Status Badge (Top Right absolute or in Row?)
                   // Reference shows "Direct" badge floating or inline. Let's put it inline.
                ],
              ),
            ),
            
            // Dashed Divider
            Row(
              children: List.generate(30, (index) => Expanded(
                child: Container(
                  height: 1,
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.3),
                ),
              )),
            ),

            // Bottom: Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${invoice.invoiceNumber}', 
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    currencyFormat.format(invoice.totalAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary, // Green usually
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(ThemeData theme, bool isFilled) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isFilled ? theme.colorScheme.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}
