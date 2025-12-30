import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/invoice_split_layout.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _invoiceService = InvoiceService();
  final _authService = AuthService();
  
  // Customer & Bill Details
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _invoiceNumberController = TextEditingController(text: 'IN${DateFormat('yyyyMMddHHmm').format(DateTime.now())}');
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

      await _invoiceService.createInvoice(invoice, _items);
      if (mounted) {
        AppTheme.showToast(context, 'Invoice saved successfully');
        Navigator.pop(context);
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


  // ... (previous methods)

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

  // ... (save method remains same)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: SafeArea(
          child: ConstrainedCenter(
            maxWidth: 600,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassContainer(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildCustomerSection(),
                      const Divider(height: 48),
                      _buildItemEntrySection(),
                      const SizedBox(height: 24),
                      _buildItemsList(),
                      const Divider(height: 48),
                      _buildSummarySection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        tablet: SafeArea(
          child: InvoiceSplitLayout(
            leftSide: SingleChildScrollView( // Form on Left
               physics: const BouncingScrollPhysics(),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _buildTopBar(showClear: false),
                   const SizedBox(height: 24),
                   _buildCustomerSection(),
                   const Divider(height: 32),
                   _buildItemEntrySection(),
                 ],
               ),
            ),
            rightSide: SingleChildScrollView( // Preview on Right
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildPreviewHeader(),
                   const SizedBox(height: 16),
                   _buildItemsList(),
                   const Divider(height: 32),
                   _buildSummarySection(),
                   const SizedBox(height: 32),
                   _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (rest of build methods)

  Widget _buildTopBar({bool showClear = true}) {
    // Header Row
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF1A1C1E)),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Invoice',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            Text('Enter bill details', style: TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        if (showClear) ...[
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _customerNameController.clear();
                _customerPhoneController.clear();
                _vehicleNumberController.clear();
                _items.clear();
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Match the structure of _buildTopBar for alignment
        // Left side has IconButton(48px) + Gap(8)
        const SizedBox(width: 48 + 8), 
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice Preview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))), // Match font size 24
              Text('Real-time updates', style: TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _customerNameController.clear();
              _customerPhoneController.clear();
              _vehicleNumberController.clear();
              _items.clear();
            });
          },
          child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text('No items added yet', style: TextStyle(color: Colors.black38)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bill Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(_items.length, (index) {
          final item = _items[index];
          return InkWell( // Make draggable or clickable to edit
            onTap: () => _editItem(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Text('${item.quantity} x ₹${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            if(item.discountItem > 0)
                              Text(
                                '  (Disc: ${item.isDiscountItemPercentage ? "${item.discountItem}%" : "₹${item.discountItem}"})',
                                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('₹${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => setState(() => _items.removeAt(index)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSaveButton() {
     return _isSaving 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : CustomButton(text: 'Save Invoice', onPressed: _saveInvoice);
  }

  Widget _buildCustomerSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _customerNameController,
                label: 'Customer Name',
                hint: 'Enter name',
                prefixIcon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _customerPhoneController,
                label: 'Phone Number',
                hint: 'Enter phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _vehicleNumberController,
                label: 'Vehicle Number',
                hint: 'e.g. TS 08 AB 1234',
                prefixIcon: Icons.directions_car_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildDatePicker()),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                const SizedBox(width: 12),
                Text(DateFormat('MM/dd/yyyy').format(_selectedDate), style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _itemNameController,
          label: 'Item Name',
          hint: 'Enter item name',
          prefixIcon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: _itemQuantityController,
                label: 'Qty',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: _itemPriceController,
                label: 'Price',
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
             Expanded(
              flex: 3,
              child: CustomTextField(
                controller: _itemDiscountController,
                label: 'Discount',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            _buildToggle(
              isPercentage: _isItemDiscountPercentage, 
              onTap: (val) => setState(() => _isItemDiscountPercentage = val)
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text('Add to Bill'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle({required bool isPercentage, required Function(bool) onTap}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('₹', !isPercentage, () => onTap(false)),
          _buildToggleOption('%', isPercentage, () => onTap(true)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }


  Widget _buildSummarySection() {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Text('Discount on Total', style: TextStyle(color: Colors.black54))),
            _buildToggle(
              isPercentage: _isGlobalDiscountPercentage, 
              onTap: (val) => setState(() => _isGlobalDiscountPercentage = val)
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _globalDiscountController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true, contentPadding: EdgeInsets.zero),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Text('GST (%)', style: TextStyle(color: Colors.black54))),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _gstController,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true, contentPadding: EdgeInsets.zero),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSummaryRow('Grand Total', '₹${_grandTotal.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.black54, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        Text(value, style: TextStyle(color: isBold ? AppTheme.primaryColor : Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.bold, fontSize: isBold ? 22 : 14)),
      ],
    );
  }
}
