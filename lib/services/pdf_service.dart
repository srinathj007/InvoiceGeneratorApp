import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';
import '../models/business_profile.dart';

class PdfService {
  pw.MemoryImage? eicherLogo;
  pw.MemoryImage? mahindraLogo;
  pw.MemoryImage? swarajLogo;
  pw.MemoryImage? bharatLogo;
  pw.MemoryImage? signatureImg;

  // SAFE loader
  Future<pw.MemoryImage?> _loadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null; // asset missing → fallback
    }
  }

  Future<void> _loadAssets() async {
    eicherLogo = await _loadImage('assets/eicher.png');
    mahindraLogo = await _loadImage('assets/mahindra.png');
    swarajLogo = await _loadImage('assets/swaraj.png');
    bharatLogo = await _loadImage('assets/bharatbenz.png');
    signatureImg = await _loadImage('assets/signature.png');
  }

  /// MAIN ENTRY
  Future<Uint8List> generateInvoice(
    Invoice invoice,
    BusinessProfile profile,
  ) async {
    await _loadAssets();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Stack(
            children: [
              // WATERMARK
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.08,
                  child: pw.Text(
                    profile.businessName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 80,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(profile),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  pw.SizedBox(height: 10),

                  _buildInfoRow(invoice),
                  pw.SizedBox(height: 20),

                  _buildTable(invoice),
                  pw.Spacer(),

                  _buildSignatures(),
                  pw.SizedBox(height: 15),
                  _buildThankYou(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ================= HEADER =================
  pw.Widget _buildHeader(BusinessProfile profile) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _logo(eicherLogo, "EICHER"),
            pw.SizedBox(width: 10),
            pw.Text(
              profile.businessName.toUpperCase(),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(width: 10),
            _logo(mahindraLogo, "MAHINDRA"),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          profile.address,
          textAlign: pw.TextAlign.center,
          style:  pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _logo(swarajLogo, "SWARAJ"),
            pw.Column(
              children: [
                pw.Text(
                  "Prop: ${profile.proprietor}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.Text(
                  "Ph: ${profile.phoneNumbers}",
                  style:  pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
            _logo(bharatLogo, "BHARAT"),
          ],
        ),
      ],
    );
  }

  // Dummy logo fallback
  pw.Widget _logo(pw.MemoryImage? img, String label) {
    if (img != null) {
      return pw.Image(img, height: 30);
    }
    return pw.Container(
      height: 30,
      width: 60,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Text(label, style:  pw.TextStyle(fontSize: 7)),
    );
  }

  // ================= INFO =================
  pw.Widget _buildInfoRow(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _label("Customer Name", invoice.customerName),
            _label("Phone", invoice.customerPhone ?? ""),
            _label("Vehicle", invoice.vehicleNumber ?? ""),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _label("Invoice Number", invoice.invoiceNumber),
            _label("Date", DateFormat('dd-MM-yyyy').format(invoice.date)),
          ],
        ),
      ],
    );
  }

  pw.Widget _label(String label, String value) {
    return pw.Padding(
      padding:  pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: "$label: ",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.TextSpan(
              text: value,
              style:  pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TABLE =================
  pw.Widget _buildTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths:  {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration:  pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell("Item Name", bold: true),
            _cell("Qty", bold: true),
            _cell("Price", bold: true),
            _cell("Amount", bold: true),
          ],
        ),
        ...invoice.items.map(
          (i) => pw.TableRow(
            children: [
              _cell(i.itemName),
              _cell(i.quantity.toStringAsFixed(0)),
              _cell("₹${i.price.toStringAsFixed(2)}"),
              _cell("₹${i.amount.toStringAsFixed(2)}"),
            ],
          ),
        ),
        pw.TableRow(
          decoration:  pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Container(),
            pw.Container(),
            _cell("Total", bold: true),
            _cell("₹${invoice.totalAmount.toStringAsFixed(2)}", bold: true),
          ],
        ),
      ],
    );
  }

  pw.Widget _cell(String t, {bool bold = false}) {
    return pw.Padding(
      padding:  pw.EdgeInsets.all(6),
      child: pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ================= FOOTER =================
  pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signature("Receiver's Signature"),
        _signature("Cashier's Signature"),
        pw.Column(
          children: [
            signatureImg != null
                ? pw.Image(signatureImg!, height: 40)
                : pw.Container(
                    height: 40,
                    width: 80,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child:  pw.Text("Signature", style: pw.TextStyle(fontSize: 8)),
                  ),
            pw.Text("Prop. Signature", style:  pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  pw.Widget _signature(String label) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Container(width: 80, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 3),
        pw.Text(label, style: pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  pw.Widget _buildThankYou() {
    return pw.Center(
      child: pw.Text(
        "Thank You! Visit Again",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
