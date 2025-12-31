import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../services/invoice_service.dart';
import '../services/profile_service.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_layout.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Invoice? invoiceToEdit;
  const CreateInvoiceScreen({super.key, this.invoiceToEdit});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _invoiceService = InvoiceService();
  final _profileService = ProfileService();
  final _authService = AuthService();
  
  BusinessProfile? _profile;
  
  // Customer & Bill Details
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  late TextEditingController _invoiceNumberController;
  DateTime _selectedDate = DateTime.now();
  
  // Item Entry Controllers
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController(text: '1');
  final _itemPriceController = TextEditingController();
  final _itemDiscountController = TextEditingController(text: '0');
  bool _isItemDiscountPercentage = false;
  
  // Global Totals Controllers
  final _globalDiscountController = TextEditingController(text: '0');
  bool _isGlobalDiscountPercentage = false;
  final _gstController = TextEditingController(text: '0');

  final List<InvoiceItem> _items = [];
  bool _isSaving = false;

  // FocusNodes for "Clear on Focus" logic
  final _qtyFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _discountFocus = FocusNode();
  final _globalDiscountFocus = FocusNode();
  final _gstFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _invoiceNumberController = TextEditingController(text: 'IN${DateFormat('yyyyMMddHHmm').format(DateTime.now())}');
    
    if (widget.invoiceToEdit != null) {
      _loadInvoiceData(widget.invoiceToEdit!);
    }
    _loadBusinessProfile();

    // Setup "Clear on Focus" listeners
    _qtyFocus.addListener(() => _onFocusChange(_itemQuantityController, _qtyFocus.hasFocus));
    _priceFocus.addListener(() => _onFocusChange(_itemPriceController, _priceFocus.hasFocus));
    _discountFocus.addListener(() => _onFocusChange(_itemDiscountController, _discountFocus.hasFocus));
    _globalDiscountFocus.addListener(() => _onFocusChange(_globalDiscountController, _globalDiscountFocus.hasFocus));
    _gstFocus.addListener(() => _onFocusChange(_gstController, _gstFocus.hasFocus));
  }

  void _onFocusChange(TextEditingController controller, bool hasFocus) {
    if (hasFocus && (controller.text == '0' || controller.text == '0.0')) {
      controller.clear();
    }
  }

  Future<void> _loadBusinessProfile() async {
    final profile = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
      });
    }
  }

  void _loadInvoiceData(Invoice invoice) {
    _customerNameController.text = invoice.customerName;
    _customerPhoneController.text = invoice.customerPhone ?? '';
    _vehicleNumberController.text = invoice.vehicleNumber ?? '';
    _invoiceNumberController.text = invoice.invoiceNumber;
    _selectedDate = invoice.date;
    
    _globalDiscountController.text = invoice.discountTotal.toString();
    _isGlobalDiscountPercentage = invoice.isDiscountTotalPercentage;
    _gstController.text = invoice.gstPercentage.toString();
    
    setState(() {
      _items.clear();
      _items.addAll(invoice.items);
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _vehicleNumberController.dispose();
    _invoiceNumberController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    _itemPriceController.dispose();
    _itemDiscountController.dispose();
    _globalDiscountController.dispose();
    _gstController.dispose();
    
    _qtyFocus.dispose();
    _priceFocus.dispose();
    _discountFocus.dispose();
    _globalDiscountFocus.dispose();
    _gstFocus.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.amount);
  }

  double get _discountValue {
    final discount = double.tryParse(_globalDiscountController.text) ?? 0;
    if (_isGlobalDiscountPercentage) {
      return _subtotal * (discount / 100);
    }
    return discount;
  }

  double get _grandTotal {
    final afterDiscount = _subtotal - _discountValue;
    final gst = double.tryParse(_gstController.text) ?? 0;
    return afterDiscount + (afterDiscount * (gst / 100));
  }

  Future<void> _saveInvoice() async {
    if (_customerNameController.text.isEmpty) {
      AppTheme.showToast(context, 'Customer Name is required', isError: true);
      return;
    }
    if (_items.isEmpty) {
      AppTheme.showToast(context, 'Please add at least one item', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('No user');

      final invoice = Invoice(
        id: widget.invoiceToEdit?.id,
        userId: userId,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        date: _selectedDate,
        invoiceNumber: _invoiceNumberController.text.trim(),
        subtotal: _subtotal,
        discountTotal: double.tryParse(_globalDiscountController.text) ?? 0,
        isDiscountTotalPercentage: _isGlobalDiscountPercentage,
        gstPercentage: double.tryParse(_gstController.text) ?? 0,
        totalAmount: _grandTotal,
      );

      if (widget.invoiceToEdit != null) {
        await _invoiceService.updateInvoice(invoice, _items);
        if (mounted) AppTheme.showToast(context, 'Invoice updated successfully');
      } else {
        await _invoiceService.createInvoice(invoice, _items);
        if (mounted) AppTheme.showToast(context, 'Invoice saved successfully');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showToast(context, 'Error saving invoice: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    final qty = double.tryParse(_itemQuantityController.text) ?? 0;
    final price = double.tryParse(_itemPriceController.text) ?? 0;
    final discount = double.tryParse(_itemDiscountController.text) ?? 0;

    if (name.isEmpty || qty <= 0 || price <= 0) {
      AppTheme.showToast(context, 'Please enter valid item details', isError: true);
      return;
    }

    double amount;
    if (_isItemDiscountPercentage) {
      amount = (qty * price) * (1 - (discount / 100));
    } else {
      amount = (qty * price) - discount;
    }
    
    // Validate that discount doesn't exceed amount
    if (amount < 0) amount = 0;

    setState(() {
      _items.add(InvoiceItem(
        itemName: name,
        quantity: qty,
        price: price,
        discountItem: discount,
        isDiscountItemPercentage: _isItemDiscountPercentage,
        amount: amount,
      ));
      
      _clearItemForm();
    });
  }

  void _editItem(int index) {
    final item = _items[index];
    setState(() {
      _itemNameController.text = item.itemName;
      _itemQuantityController.text = item.quantity.toString();
      _itemPriceController.text = item.price.toString();
      _itemDiscountController.text = item.discountItem.toString();
      _isItemDiscountPercentage = item.isDiscountItemPercentage;
      
      _items.removeAt(index);
    });
  }
  
  void _clearItemForm() {
    _itemNameController.clear();
    _itemQuantityController.text = '1';
    _itemPriceController.clear();
    _itemDiscountController.text = '0';
    _isItemDiscountPercentage = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _customerNameController.clear();
                _customerPhoneController.clear();
                _vehicleNumberController.clear();
                _items.clear();
              });
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildCompactLayout(),
        tablet: _buildSplitLayout(),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCustomerCard(),
          const SizedBox(height: 16),
          _buildItemFormCard(),
          const SizedBox(height: 16),
          _buildItemsList(),
          const SizedBox(height: 24),
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSplitLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure equal height
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCustomerCard(),
                const SizedBox(height: 24),
                _buildItemFormCard(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4), 
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.3),
            padding: const EdgeInsets.all(24),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Invoice Preview', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildItemsList(isScrollable: true),
                    ),
                    const Divider(height: 32),
                    _buildSummaryCard(showAsCard: false),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
    final customLabel = (_profile?.customFieldLabel?.isNotEmpty == true) ? _profile!.customFieldLabel! : 'Reference No';
    final customHint = (_profile?.customFieldPlaceholder?.isNotEmpty == true) ? _profile!.customFieldPlaceholder! : 'Enter detail...';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Customer Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _customerNameController,
              label: 'Customer Name',
              hint: 'Enter customer name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _customerPhoneController,
              label: 'Mobile Number',
              hint: 'Enter mobile number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _vehicleNumberController,
              label: customLabel,
              hint: customHint,
              prefixIcon: Icons.label_outline,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Invoice Date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Item', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.shopping_bag_outlined)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemQuantityController,
                    focusNode: _qtyFocus,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _itemPriceController,
                    focusNode: _priceFocus,
                    decoration: const InputDecoration(labelText: 'Price', prefixText: '₹'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Discount', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(value: false, label: Text('₹')),
                        ButtonSegment<bool>(value: true, label: Text('%')),
                      ],
                      selected: {_isItemDiscountPercentage},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _isItemDiscountPercentage = newSelection.first;
                        });
                      },
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _itemDiscountController,
                  focusNode: _discountFocus,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add to Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList({bool isScrollable = false}) {
    if (_items.isEmpty) {
      final placeholder = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'No items added',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
      
      return isScrollable ? SingleChildScrollView(child: placeholder) : placeholder;
    }

    final listWidget = ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${item.quantity} x ₹${item.price.toStringAsFixed(2)} - Disc: ${item.isDiscountItemPercentage ? "${item.discountItem}%" : "₹${item.discountItem}"}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => setState(() => _items.removeAt(index)),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            onTap: () => _editItem(index),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${_items.length})', 
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)
        ),
        const SizedBox(height: 8),
        isScrollable ? Expanded(child: listWidget) : listWidget,
      ],
    );
  }

  Widget _buildSummaryCard({bool showAsCard = true}) {
    final content = Column(
      children: [
            _buildSummaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            
            // Discount Row
            Row(
              children: [
                const Text('Discount', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(width: 4),
                SizedBox(
                  width: 70,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(value: false, label: Text('₹', style: TextStyle(fontSize: 12))),
                      ButtonSegment<bool>(value: true, label: Text('%', style: TextStyle(fontSize: 12))),
                    ],
                    selected: {_isGlobalDiscountPercentage},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _isGlobalDiscountPercentage = newSelection.first;
                      });
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 55,
                  child: TextField(
                    controller: _globalDiscountController,
                    focusNode: _globalDiscountFocus,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true, 
                      contentPadding: EdgeInsets.all(6),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.end,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Spacer(),
                if (_discountValue > 0)
                  Text(
                    '- ₹${_discountValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  )
                else
                  Text(
                    '₹0.00',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // GST Row
            Row(
              children: [
                const Text('GST (%)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 55,
                  child: TextField(
                    controller: _gstController,
                    focusNode: _gstFocus,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true, 
                      contentPadding: EdgeInsets.all(6),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.end,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Spacer(),
                if (double.tryParse(_gstController.text) != null && (double.tryParse(_gstController.text) ?? 0) > 0)
                  Text(
                    '+ ₹${((_subtotal - _discountValue) * ((double.tryParse(_gstController.text) ?? 0) / 100)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  )
                else
                  Text(
                    '₹0.00',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            _buildSummaryRow(
              'Grand Total', 
              '₹${_grandTotal.toStringAsFixed(2)}', 
              isBold: true, 
              color: Theme.of(context).colorScheme.primary
            ),
      ],
    );

    if (!showAsCard) return content;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 20 : 14,
            color: color
          )
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSaving ? null : _saveInvoice,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
        child: _isSaving 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Save Invoice', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
