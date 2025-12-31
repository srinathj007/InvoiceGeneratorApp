import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../models/invoice.dart';
import '../models/business_profile.dart';

class PdfService {
  pw.MemoryImage? eicherLogo;
  pw.MemoryImage? mahindraLogo;
  pw.MemoryImage? swarajLogo;
  pw.MemoryImage? bharatLogo;
  pw.MemoryImage? signatureImg;

  // Colors matching the app theme (approximate)
  final primaryColor = PdfColor.fromInt(0xFF2196F3); // Blue
  final accentColor = PdfColor.fromInt(0xFF1976D2);
  final lightColor = PdfColor.fromInt(0xFFE3F2FD);
  final textColor = PdfColor.fromInt(0xFF2C3E50);

  // SAFE loader for root assets
  Future<pw.MemoryImage?> _loadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // SAFE loader for network images
  Future<pw.MemoryImage?> _loadNetworkImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadAssets() async {
    eicherLogo = await _loadImage('assets/eicher.png');
    mahindraLogo = await _loadImage('assets/mahindra.png');
    swarajLogo = await _loadImage('assets/swaraj.png');
    bharatLogo = await _loadImage('assets/bharatbenz.png');
    signatureImg = await _loadImage('assets/signature.png');
  }

  Future<Uint8List> generateInvoice(
    Invoice invoice,
    BusinessProfile profile,
  ) async {
    // Load root assets
    await _loadAssets();
    
    // Load dynamic assets
    final businessLogo = await _loadNetworkImage(profile.logoUrl);
    final businessSignature = await _loadNetworkImage(profile.signatureUrl);
    final custom1 = await _loadNetworkImage(profile.customLogo1Url);
    final custom2 = await _loadNetworkImage(profile.customLogo2Url);
    final custom3 = await _loadNetworkImage(profile.customLogo3Url);
    final custom4 = await _loadNetworkImage(profile.customLogo4Url);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(profile, businessLogo),
              pw.SizedBox(height: 30),
              _buildInfoRow(invoice, profile),
              pw.SizedBox(height: 30),
              _buildTable(invoice),
              pw.SizedBox(height: 20),
              _buildSummary(invoice),
              pw.Spacer(),
              _buildCustomLogos(custom1, custom2, custom3, custom4),
              pw.SizedBox(height: 20),
              _buildSignatures(businessSignature),
              pw.SizedBox(height: 15),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(BusinessProfile profile, pw.MemoryImage? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: lightColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 50,
                  height: 50,
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 12),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    profile.businessName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(profile.address, style: const pw.TextStyle(fontSize: 9)),
                  pw.Text("Ph: ${profile.phoneNumbers}", style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(
                  "INVOICE",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(Invoice invoice, BusinessProfile profile) {
    final customLabel = (profile.customFieldLabel?.isNotEmpty == true) ? profile.customFieldLabel! : 'Reference';
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionLabel("BILL TO"),
            pw.Text(invoice.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            if (invoice.customerPhone?.isNotEmpty == true) pw.Text("Ph: ${invoice.customerPhone}", style: const pw.TextStyle(fontSize: 10)),
            if (invoice.vehicleNumber?.isNotEmpty == true) pw.Text("$customLabel: ${invoice.vehicleNumber}", style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _sectionLabel("DETAILS"),
            pw.Text("Invoice #: ${invoice.invoiceNumber}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text("Date: ${DateFormat('dd MMM yyyy').format(invoice.date)}", style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _sectionLabel(String t) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: 8,
          color: primaryColor,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: [
            _cell("ITEM DESCRIPTION", bold: true, color: PdfColors.white),
            _cell("QTY", bold: true, color: PdfColors.white, align: pw.TextAlign.center),
            _cell("PRICE", bold: true, color: PdfColors.white, align: pw.TextAlign.right),
            _cell("TOTAL", bold: true, color: PdfColors.white, align: pw.TextAlign.right),
          ],
        ),
        ...invoice.items.map(
          (i) => pw.TableRow(
            children: [
              _cell(i.itemName),
              _cell(i.quantity.toStringAsFixed(0), align: pw.TextAlign.center),
              _cell("₹${i.price.toStringAsFixed(2)}", align: pw.TextAlign.right),
              _cell("₹${i.amount.toStringAsFixed(2)}", bold: true, align: pw.TextAlign.right),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _cell(String t, {bool bold = false, PdfColor? color, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        t,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildSummary(Invoice invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 180,
        child: pw.Column(
          children: [
            _summaryRow("Subtotal", "₹${invoice.subtotal.toStringAsFixed(2)}"),
            if (invoice.discountTotal > 0)
              _summaryRow(
                "Discount", 
                "- ₹${(invoice.subtotal - (invoice.totalAmount / (1 + (invoice.gstPercentage / 100)))).toStringAsFixed(2)}",
                color: PdfColors.red,
              ),
            if (invoice.gstPercentage > 0)
              _summaryRow(
                "GST (${invoice.gstPercentage}%)", 
                "+ ₹${(invoice.totalAmount - (invoice.totalAmount / (1 + (invoice.gstPercentage / 100)))).toStringAsFixed(2)}",
                color: PdfColors.green,
              ),
            pw.Divider(color: PdfColors.grey300),
            _summaryRow(
              "Grand Total", 
              "₹${invoice.totalAmount.toStringAsFixed(2)}", 
              bold: true, 
              fontSize: 14,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _summaryRow(String label, String value, {bool bold = false, double fontSize = 10, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  pw.Widget _buildSignatures(pw.MemoryImage? signature) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _sigLine("Receiver's Signature"),
        _sigLine("Cashier's Signature"),
        pw.Column(
          children: [
            signature != null
                ? pw.Image(signature, height: 40)
                : pw.Container(height: 40, width: 80, decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey200))),
            pw.SizedBox(height: 4),
            pw.Text("Authorized Signature", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomLogos(pw.MemoryImage? c1, pw.MemoryImage? c2, pw.MemoryImage? c3, pw.MemoryImage? c4) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        if (c1 != null) pw.Container(height: 30, width: 60, child: pw.Image(c1, fit: pw.BoxFit.contain)),
        if (c2 != null) pw.Container(height: 30, width: 60, child: pw.Image(c2, fit: pw.BoxFit.contain)),
        if (c3 != null) pw.Container(height: 30, width: 60, child: pw.Image(c3, fit: pw.BoxFit.contain)),
        if (c4 != null) pw.Container(height: 30, width: 60, child: pw.Image(c4, fit: pw.BoxFit.contain)),
      ],
    );
  }

  pw.Widget _sigLine(String label) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Container(width: 100, height: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text("Thank you for your business!", style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Container(height: 2, width: 40, color: lightColor),
        ],
      ),
    );
  }
}
