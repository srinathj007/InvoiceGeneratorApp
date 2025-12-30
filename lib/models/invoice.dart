class Invoice {
  final String? id;
  final String userId;
  final String customerName;
  final String? customerPhone;
  final String? vehicleNumber;
  final DateTime date;
  final String invoiceNumber;
  final double subtotal;
  final double discountTotal;
  final bool isDiscountTotalPercentage;
  final double gstPercentage;
  final double totalAmount;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.userId,
    required this.customerName,
    this.customerPhone,
    this.vehicleNumber,
    required this.date,
    required this.invoiceNumber,
    required this.subtotal,
    required this.discountTotal,
    required this.isDiscountTotalPercentage,
    required this.gstPercentage,
    required this.totalAmount,
    this.items = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json, [List<InvoiceItem> items = const []]) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      vehicleNumber: json['vehicle_number'],
      date: DateTime.parse(json['invoice_date']),
      invoiceNumber: json['invoice_number'],
      subtotal: (json['subtotal'] as num).toDouble(),
      discountTotal: (json['discount_total'] as num).toDouble(),
      isDiscountTotalPercentage: json['is_discount_total_percentage'] ?? false,
      gstPercentage: (json['gst_percentage'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'vehicle_number': vehicleNumber,
      'invoice_date': date.toIso8601String().split('T')[0],
      'invoice_number': invoiceNumber,
      'subtotal': subtotal,
      'discount_total': discountTotal,
      'is_discount_total_percentage': isDiscountTotalPercentage,
      'gst_percentage': gstPercentage,
      'total_amount': totalAmount,
    };
  }
}

class InvoiceItem {
  final String? id;
  final String? invoiceId;
  final String itemName;
  final double quantity;
  final double price;
  final double discountItem;
  final bool isDiscountItemPercentage;
  final double amount;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.discountItem,
    required this.isDiscountItemPercentage,
    required this.amount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoice_id'],
      itemName: json['item_name'],
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      discountItem: (json['discount_item'] as num).toDouble(),
      isDiscountItemPercentage: json['is_discount_item_percentage'] ?? false,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'discount_item': discountItem,
      'is_discount_item_percentage': isDiscountItemPercentage,
      'amount': amount,
    };
  }
}
