import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../models/invoice.dart';
import '../models/business_profile.dart';

class PdfService {

  // ---------------- LOADERS ----------------

  Future<pw.MemoryImage?> _loadAsset(String path) async {
    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  Future<pw.MemoryImage?> _loadNetworkImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return pw.MemoryImage(res.bodyBytes);
      }
    } catch (_) {}
    return null;
  }

  Future<pw.Font> _loadAssetFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data.buffer.asByteData());
  }

  String _formatCurrency(double v) => "Rs. ${v.toStringAsFixed(2)}";

  // ---------------- MAIN ----------------

  Future<Uint8List> generateInvoice(
    Invoice invoice,
    BusinessProfile profile,
  ) async {
    // Restore all logos
    final logoTL = await _loadNetworkImage(profile.customLogo1Url);
    final logoTR = await _loadNetworkImage(profile.customLogo2Url);
    final logoML = await _loadNetworkImage(profile.customLogo3Url);
    final logoMR = await _loadNetworkImage(profile.customLogo4Url);
    final signature = await _loadNetworkImage(profile.signatureUrl);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          theme: pw.ThemeData.withFont(
            base: pw.Font.times(),
            bold: pw.Font.timesBold(),
          ),
          buildBackground: (context) => _buildWatermark(profile),
        ),
        header: (context) => pw.Column(
          children: [
            _buildHeader(
              profile,
              logoTL,
              logoTR,
              logoML,
              logoMR,
              pw.Font.times(),
              pw.Font.timesBold(),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 12),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (context) {
          final regular = pw.Font.times();
          final bold = pw.Font.timesBold();

          return [
            _buildInfo(invoice, regular, bold),
            pw.SizedBox(height: 12),
            _buildTable(invoice, regular, bold),
            pw.SizedBox(height: 35),
            _buildSignatures(signature, regular, bold),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                "Thank You! Visit Again",
                style: pw.TextStyle(font: bold, fontSize: 14),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ---------------- HEADER (4 LOGOS RESTORED) ----------------

  pw.Widget _buildHeader(
    BusinessProfile p,
    pw.MemoryImage? tl,
    pw.MemoryImage? tr,
    pw.MemoryImage? ml,
    pw.MemoryImage? mr,
    pw.Font r,
    pw.Font b,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(width: 70, height: 40, child: tl != null ? pw.Image(tl) : null),
            pw.Expanded(
              child: pw.Center(
                child: pw.FittedBox(
                  child: pw.Text(
                    p.businessName.toUpperCase(),
                    style: pw.TextStyle(font: b, fontSize: 28),
                  ),
                ),
              ),
            ),
            pw.Container(width: 70, height: 40, child: tr != null ? pw.Image(tr) : null),
          ],
        ),
        pw.Text(
          p.address,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(width: 60, height: 35, child: ml != null ? pw.Image(ml) : null),
            pw.Column(
              children: [
                if (p.gstin?.isNotEmpty == true)
                  pw.Text(
                    "GSTIN: ${p.gstin}",
                    style: pw.TextStyle(font: b, fontSize: 12),
                  ),
                pw.Text(
                  "Prop: ${p.proprietor}",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Ph: ${p.phoneNumbers}",
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.Container(width: 60, height: 35, child: mr != null ? pw.Image(mr) : null),
          ],
        ),
      ],
    );
  }

  // ---------------- INFO ----------------

  pw.Widget _buildInfo(Invoice i, pw.Font r, pw.Font b) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _info("Customer Name:", i.customerName, r, b),
            _info("Phone:", i.customerPhone ?? "", r, b),
            _info("Vehicle:", i.vehicleNumber ?? "", r, b),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _info("Invoice No:", i.invoiceNumber, r, b),
            _info("Date:", DateFormat('dd-MM-yyyy').format(i.date), r, b),
          ],
        ),
      ],
    );
  }

  pw.Widget _info(String l, String v, pw.Font r, pw.Font b) {
    return pw.Row(
      children: [
        pw.Text(l, style: pw.TextStyle(font: b, fontSize: 11)),
        pw.SizedBox(width: 4),
        pw.Text(v, style: pw.TextStyle(font: r, fontSize: 11)),
      ],
    );
  }

  // ---------------- TABLE (DISCOUNT % FIXED) ----------------

  pw.Widget _buildTable(Invoice invoice, pw.Font r, pw.Font b) {
    final headerBg = PdfColor.fromInt(0xFFF0F4F8);
    final gstAmount =
        invoice.totalAmount - (invoice.totalAmount / (1 + invoice.gstPercentage / 100));

        final totalMrp = invoice.items.fold<double>(
  0,
  (sum, e) => sum + (e.price * e.quantity),
);

final totalDiscount = invoice.items.fold<double>(
  0,
  (sum, e) {
    final mrp = e.price * e.quantity;
    final discount = e.isDiscountItemPercentage
        ? mrp * (e.discountItem / 100)
        : e.discountItem * e.quantity;
    return sum + discount;
  },
);

final totalAmount = totalMrp - totalDiscount;


    return pw.Table(
      border: pw.TableBorder.all(width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(10),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(4),
        3: pw.FlexColumnWidth(6),
        4: pw.FlexColumnWidth(4),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerBg),
          children: [
            _cell("Item Name", b),
            _cell("Qty", b, center: true),
            _cell("MRP", b, right: true),
            _cell("Discount", b, right: true),
            _cell("Amount", b, right: true),
          ],
        ),

        ...invoice.items.map((e) {
          final mrp = e.price * e.quantity;
          final discount = e.isDiscountItemPercentage
              ? mrp * (e.discountItem / 100)
              : e.discountItem * e.quantity;

          // final discountText = e.isDiscountItemPercentage
          //     ? "-${_formatCurrency(discount)} (${e.discountItem.toStringAsFixed(0)}%)"
          //     : "-${_formatCurrency(discount)}";
          final discountPct =
    mrp > 0 ? (discount / mrp) * 100 : 0;

final discountText =
    "-${_formatCurrency(discount)} (${discountPct.toStringAsFixed(0)}%)";


          return pw.TableRow(
            children: [
              _cell(e.itemName, r),
              _cell(e.quantity.toString(), r, center: true),
              _cell(_formatCurrency(mrp), r, right: true),
              _cell(discountText, r, right: true),
              _cell(_formatCurrency(mrp - discount), r, right: true),
            ],
          );
        }),

        // _summaryRow("Total:", invoice.subtotal, b, headerBg),
        pw.TableRow(
  decoration: pw.BoxDecoration(color: headerBg),
  children: [
    _cell("", b, bg: headerBg), 
    _cell("Total:", b, right: true),
    _cell(_formatCurrency(totalMrp), b, right: true),
    _cell("-${_formatCurrency(totalDiscount)}", b, right: true),
    _cell(_formatCurrency(totalAmount), b, right: true),
  ],
),

        if (invoice.discountTotal > 0)
          _summaryRow("Additional Discount:", -invoice.discountTotal, b, headerBg),
        _summaryRow("GST (${invoice.gstPercentage}%):", gstAmount, b, headerBg),
        _summaryRow("Grand Total:", invoice.totalAmount, b, headerBg),
      ],
    );
  }

  pw.TableRow _summaryRow(String l, double v, pw.Font b, PdfColor bg) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        _cell("", b, bg: bg),
        _cell("", b, bg: bg),
        _cell("", b, bg: bg),
        _cell(l, b, right: true, bg: bg),
        _cell(_formatCurrency(v), b, right: true, bg: bg),
      ],
    );
  }

  // ---------------- CELL ----------------

  pw.Widget _cell(
    String t,
    pw.Font f, {
    bool right = false,
    bool center = false,
    PdfColor? bg,
  }) {
    return pw.Container(
      height: 26,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
      alignment: center
          ? pw.Alignment.center
          : right
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
      color: bg,
      child: pw.Text(t, style: pw.TextStyle(font: f, fontSize: 11)),
    );
  }

  // ---------------- SIGNATURES ----------------

pw.Widget _buildSignatures(
  pw.MemoryImage? sign,
  pw.Font regular,
  pw.Font bold,
) {
  return pw.Column(
    children: [
      pw.SizedBox(height: 30),

      // ---- Single baseline ----
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // Receiver
          pw.Container(
            width: 150,
            height: 1,
          ),

          // Cashier
          pw.Container(
            width: 150,
            height: 1,
          ),

          // Proprietor (with signature image)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (sign != null)
                pw.Image(sign, height: 35)
              else
                pw.SizedBox(height: 35),
              pw.Container(
                width: 150,
                height: 1,
              ),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 6),

      // ---- Labels ----
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              "Receiver's Signature",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: regular, fontSize: 10),
            ),
          ),
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              "Cashier's Signature",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: regular, fontSize: 10),
            ),
          ),
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              "Prop. Signature",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: bold, fontSize: 10),
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 10),
      pw.Divider(thickness: 0.6),
    ],
  );
}

  pw.Widget _buildWatermark(BusinessProfile profile) {
    // Dynamic font size for watermark to prevent cutting on long names
    double fontSize = 80;
    if (profile.businessName.length > 15) {
      fontSize = (80 * 15) / profile.businessName.length;
      if (fontSize < 35) fontSize = 35; // Don't go too small
    }

    return pw.Stack(
      children: [
        pw.Positioned(
          left: -85,
          bottom: 290,
          child: pw.Transform.rotate(
            angle: 0.90,
            child: pw.Opacity(
              opacity: 0.18,
              child: pw.Text(
                profile.businessName,
                style: pw.TextStyle(
                  font: pw.Font.timesBold(),
                  fontSize: fontSize,
                  letterSpacing: 2,
                  color: PdfColor.fromInt(0xFFFF6F6F), // light red
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
