import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../services/pdf_service.dart';
import '../services/profile_service.dart';
import '../services/invoice_service.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import 'create_invoice_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice _invoice;
  final _profileService = ProfileService();
  final _invoiceService = InvoiceService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    if (_invoice.items.isEmpty) {
      _refreshInvoice();
    }
  }

  Future<void> _refreshInvoice() async {
    if (_invoice.id == null) return;
    final updated = await _invoiceService.getInvoiceById(_invoice.id!);
    if (updated != null && mounted) {
      setState(() => _invoice = updated);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete Invoice #${_invoice.invoiceNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        if (_invoice.id != null) {
          await _invoiceService.deleteInvoice(_invoice.id!);
          if (mounted) {
            AppTheme.showToast(context, 'Invoice deleted successfully');
            Navigator.pop(context, true); // Return true to indicate change
          }
        }
      } catch (e) {
        if (mounted) {
          AppTheme.showToast(context, 'Error deleting invoice', isError: true);
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('#${_invoice.invoiceNumber}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final profile = await _profileService.getProfile();
              if (profile != null && mounted) {
                final pdfData = await PdfService().generateInvoice(_invoice, profile);
                await Printing.sharePdf(
                  bytes: pdfData,
                  filename: 'Invoice-${_invoice.invoiceNumber}.pdf',
                );
              }
            },
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () async {
              final profile = await _profileService.getProfile();
              if (profile != null && mounted) {
                final pdfData = await PdfService().generateInvoice(_invoice, profile);
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfData,
                  name: 'Invoice-${_invoice.invoiceNumber}',
                );
              }
            },
            tooltip: 'Print Invoice',
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModernPreview(theme),
                ],
              ),
            ),
          ),
          
          // Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPreview(ThemeData theme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Business Info
            FutureBuilder<BusinessProfile?>(
              future: _profileService.getProfile(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile?.logoUrl != null) ...[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(profile!.logoUrl!, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.businessName.toUpperCase() ?? 'BUSINESS NAME',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.address ?? 'Business Address',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            'Ph: ${profile?.phoneNumbers ?? "Phone Number"}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'INVOICE',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            
            const SizedBox(height: 16),
            
            // Info Row: Customer & Invoice Details
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;
                return FutureBuilder<BusinessProfile?>(
                  future: _profileService.getProfile(), // Re-fetch or pass profile if available
                  builder: (context, snapshot) {
                    final profile = snapshot.data;
                    final customLabel = (profile?.customFieldLabel?.isNotEmpty == true) ? profile!.customFieldLabel! : "Reference";
                    return isNarrow 
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection(
                              theme,
                              'BILL TO',
                              [
                                'Name: ${_invoice.customerName}',
                                if (_invoice.customerPhone?.isNotEmpty == true) 'Ph: ${_invoice.customerPhone}',
                                if (_invoice.vehicleNumber?.isNotEmpty == true) 
                                  '$customLabel: ${_invoice.vehicleNumber}',
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              theme,
                              'DETAILS',
                              [
                                'Invoice #: ${_invoice.invoiceNumber}',
                                'Date: ${DateFormat('dd MMM yyyy').format(_invoice.date)}',
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoSection(
                                theme,
                                'BILL TO',
                                [
                                  'Name: ${_invoice.customerName}',
                                  if (_invoice.customerPhone?.isNotEmpty == true) 'Ph: ${_invoice.customerPhone}',
                                  if (_invoice.vehicleNumber?.isNotEmpty == true) 
                                    '$customLabel: ${_invoice.vehicleNumber}',
                                ],
                              ),
                            ),
                            Expanded(
                              child: _buildInfoSection(
                                theme,
                                'DETAILS',
                                [
                                  'Invoice #: ${_invoice.invoiceNumber}',
                                  'Date: ${DateFormat('dd MMM yyyy').format(_invoice.date)}',
                                ],
                                crossAxisAlignment: CrossAxisAlignment.end,
                              ),
                            ),
                          ],
                        );
                  }
                );
              }
            ),
            
            const SizedBox(height: 32),
            
            // Items Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('ITEM', style: _tableHeaderStyle(theme))),
                  Expanded(child: Text('QTY', style: _tableHeaderStyle(theme), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('PRICE', style: _tableHeaderStyle(theme), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('TOTAL', style: _tableHeaderStyle(theme), textAlign: TextAlign.right)),
                ],
              ),
            ),
            
            // Items List
            ..._invoice.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.itemName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (item.discountItem > 0)
                          Text(
                            'Discount: ${item.isDiscountItemPercentage ? "${item.discountItem}%" : "₹${item.discountItem}"}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red[400]),
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: Text('${item.quantity.toStringAsFixed(0)}', textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('₹${item.price.toStringAsFixed(2)}', textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('₹${item.amount.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            )),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            
            // Summary
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 200,
                child: Column(
                  children: [
                    _buildSummaryLine('Subtotal', '₹${(_invoice.subtotal).toStringAsFixed(2)}', theme),
                    if (_invoice.discountTotal > 0)
                      _buildSummaryLine(
                        'Discount ${_invoice.isDiscountTotalPercentage ? "(${_invoice.discountTotal}%)" : ""}', 
                        '- ₹${(_invoice.subtotal - (_invoice.totalAmount / (1 + (_invoice.gstPercentage / 100)))).toStringAsFixed(2)}', 
                        theme, 
                        valueColor: Colors.red
                      ),
                    if (_invoice.gstPercentage > 0)
                      _buildSummaryLine('GST (${_invoice.gstPercentage}%)', '+ ₹${(_invoice.totalAmount - (_invoice.totalAmount / (1 + (_invoice.gstPercentage / 100)))).toStringAsFixed(2)}', theme, valueColor: Colors.green),
                    const Divider(height: 24),
                    _buildSummaryLine('Grand Total', '₹${_invoice.totalAmount.toStringAsFixed(2)}', theme, isBold: true, fontSize: 18, valueColor: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer
            FutureBuilder<BusinessProfile?>(
              future: _profileService.getProfile(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                return Column(
                  children: [
                    if (profile?.signatureUrl != null) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 60,
                              child: Image.network(profile!.signatureUrl!, fit: BoxFit.contain),
                            ),
                            Text(
                              'Authorized Signatory',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Center(
                      child: Column(
                        children: [
                           Text(
                            'Thank you for your business!',
                            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.outline),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 40,
                            color: theme.colorScheme.primaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, List<String> lines, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        ...lines.map((line) => Text(
          line,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        )),
      ],
    );
  }

  TextStyle? _tableHeaderStyle(ThemeData theme) => theme.textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: theme.colorScheme.primary,
  );

  Widget _buildSummaryLine(String label, String value, ThemeData theme, {bool isBold = false, double fontSize = 14, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateInvoiceScreen(invoiceToEdit: _invoice)),
                );
                if (result == true) _refreshInvoice();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
