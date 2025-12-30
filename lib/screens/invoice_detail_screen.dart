import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../services/pdf_service.dart';
import '../services/profile_service.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice ${invoice.invoiceNumber}',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<BusinessProfile?>(
        future: ProfileService().getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Business profile not found.\nPlease set up your profile first.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final profile = snapshot.data!;

          return PdfPreview(
            build: (format) {
              return PdfService().generateInvoice(invoice, profile);
            },
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
          );
        },
      ),
    );
  }
}
