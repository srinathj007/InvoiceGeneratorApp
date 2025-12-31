import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';

class InvoiceView extends StatelessWidget {
  final Invoice invoice;
  final BusinessProfile profile;

  const InvoiceView({
    super.key,
    required this.invoice,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 595, // A4 width in pixels
      color: const Color(0xFFE6E6E6),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          const SizedBox(height: 8),
          const Divider(thickness: 1),
          const SizedBox(height: 8),

          _customerInfo(),
          const SizedBox(height: 12),

          _table(),
          const SizedBox(height: 30),

          _signatures(),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Thank You! Visit Again",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Column(
      children: [
        Text(
          profile.businessName.toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.address,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
        if (profile.gstin?.isNotEmpty == true)
          Text(
            "GSTIN: ${profile.gstin}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        Text(
          "Prop: ${profile.proprietor}",
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          "Ph: ${profile.phoneNumbers}",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ---------------- CUSTOMER INFO ----------------
  Widget _customerInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Customer Name:", invoice.customerName),
            _info("Phone:", invoice.customerPhone ?? ""),
            _info("Vehicle:", invoice.vehicleNumber ?? ""),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Invoice No:", invoice.invoiceNumber),
            _info("Date:", invoice.date.toString().split(' ').first),
          ],
        ),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value),
        ],
      ),
    );
  }

  // ---------------- TABLE ----------------
  Widget _table() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        _row(true, ["Item Name", "Qty", "Price", "Amount"]),
        ...invoice.items.map((item) {
          return _row(false, [
            item.itemName,
            item.quantity.toStringAsFixed(0),
            "₹${item.price.toStringAsFixed(2)}",
            "₹${item.amount.toStringAsFixed(2)}",
          ]);
        }),
        _row(true, ["", "", "Total", "₹${invoice.totalAmount.toStringAsFixed(2)}"]),
      ],
    );
  }

  TableRow _row(bool header, List<String> cells) {
    return TableRow(
      decoration: header
          ? const BoxDecoration(color: Colors.grey)
          : null,
      children: cells.map((c) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            c,
            style: TextStyle(
              fontWeight: header ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- SIGNATURES ----------------
  Widget _signatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Receiver's Signature"),
        Text("Cashier's Signature"),
        Text("Prop. Signature"),
      ],
    );
  }
}
