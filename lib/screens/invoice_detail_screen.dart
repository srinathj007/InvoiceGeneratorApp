import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:invoice_gen_app/l10n/app_localizations.dart';
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

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> with SingleTickerProviderStateMixin {
  late Invoice _invoice;
  final _profileService = ProfileService();
  final _invoiceService = InvoiceService();
  bool _isLoading = false;
  bool _isProcessing = false;
  String _processingMessage = '';
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (_invoice.items.isEmpty) {
      _refreshInvoice();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _refreshInvoice() async {
    if (_invoice.id == null) return;
    final updated = await _invoiceService.getInvoiceById(_invoice.id!);
    if (updated != null && mounted) {
      setState(() => _invoice = updated);
    }
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final isTablet = width >= 600 && width < 1200;

        return AlertDialog(
          title: Text(l10n.deleteInvoice),
          content: Container(
            width: isTablet ? width * 0.7 : null,
            child: Text(l10n.deleteConfirmation(_invoice.invoiceNumber)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        if (_invoice.id != null) {
          await _invoiceService.deleteInvoice(_invoice.id!);
          if (mounted) {
            AppTheme.showToast(context, l10n.deleteSuccess);
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

  Future<void> _handleShare() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Generating PDF...';
    });
    _rotationController.repeat();
    try {
      final profile = await _profileService.getProfile();
      if (profile != null && mounted) {
        final pdfData = await PdfService().generateInvoice(_invoice, profile);
        await Printing.sharePdf(
          bytes: pdfData,
          filename: 'Invoice-${_invoice.invoiceNumber}.pdf',
        );
      }
    } catch (e) {
      if (mounted) AppTheme.showToast(context, 'Error sharing PDF', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _rotationController.stop();
      }
    }
  }

  Future<void> _handlePrint() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Preparing Print...';
    });
    _rotationController.repeat();
    try {
      final profile = await _profileService.getProfile();
      if (profile != null && mounted) {
        final pdfData = await PdfService().generateInvoice(_invoice, profile);
        await Printing.layoutPdf(
          onLayout: (format) async => pdfData,
          name: 'Invoice-${_invoice.invoiceNumber}',
        );
      }
    } catch (e) {
      if (mounted) AppTheme.showToast(context, 'Error printing PDF', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _rotationController.stop();
      }
    }
  }

  Future<void> _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateInvoiceScreen(invoiceToEdit: _invoice)),
    );
    if (result == true) _refreshInvoice();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('#${_invoice.invoiceNumber}'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Removed share and print from AppBar to put them in premium bottom bar
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
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
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _rotationController,
                        child: Icon(
                          Icons.sync_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _processingMessage,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernPreview(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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
                          if (profile?.gstin?.isNotEmpty == true)
                            Text(
                              'GSTIN: ${profile!.gstin}',
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          Text(
                            'Prop: ${profile?.proprietor ?? "Proprietor"}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            'Ph: ${profile?.phoneNumbers ?? "Phone Number"}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
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
                  Expanded(flex: 3, child: Text(l10n.item, style: _tableHeaderStyle(theme))),
                  Expanded(child: Text(l10n.qty, style: _tableHeaderStyle(theme), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text(l10n.price, style: _tableHeaderStyle(theme), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text(l10n.total, style: _tableHeaderStyle(theme), textAlign: TextAlign.right)),
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
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStandardActionButton(
              icon: Icons.edit_outlined,
              label: l10n.edit,
              onTap: _handleEdit,
              color: theme.colorScheme.primary,
              theme: theme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStandardActionButton(
              icon: Icons.delete_outline_rounded,
              label: l10n.delete,
              onTap: _handleDelete,
              color: theme.colorScheme.error,
              theme: theme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStandardActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: _handleShare,
              color: const Color(0xFF6366F1),
              theme: theme,
              isLoading: false, // Loading is now shown globally
            ),
          ),
          const SizedBox(width: 8),
          _buildStandardActionButton(
            icon: Icons.print_outlined,
            onTap: _handlePrint,
            color: Colors.teal,
            theme: theme,
            isLoading: false, // Loading is now shown globally
          ),
        ],
      ),
    );
  }

  Widget _buildStandardActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required ThemeData theme,
    String? label,
    bool isLoading = false,
  }) {
    return Container(
      height: 52,
      width: label == null ? 52 : null,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                else
                  Icon(icon, color: color, size: 20),
                if (label != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
