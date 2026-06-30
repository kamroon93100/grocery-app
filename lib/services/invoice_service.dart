import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../constants/app_constants.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  Future<pw.Document> generateInvoice(OrderModel order) async {
    final pdf  = pw.Document();
    final date = DateTime.tryParse(order.createdAt) ?? DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:     const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    begin:  pw.Alignment.topLeft,
                    end:    pw.Alignment.bottomRight,
                    colors: [PdfColors.green700, PdfColors.green400],
                  ),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(AppConstants.storeName,
                          style: pw.TextStyle(
                            fontSize:   24,
                            color:      PdfColors.white,
                            fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(AppConstants.storeTagline,
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color:    PdfColors.white)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE',
                          style: pw.TextStyle(
                            fontSize:   28,
                            color:      PdfColors.white,
                            fontWeight: pw.FontWeight.bold)),
                        pw.Text('#${order.orderNumber}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color:    PdfColors.white)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Store Info + Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color:    PdfColors.grey,
                          fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(AppConstants.storeName,
                        style: pw.TextStyle(
                          fontSize:   13,
                          fontWeight: pw.FontWeight.bold)),
                      pw.Text(AppConstants.storeAddress,
                        style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Phone: ${AppConstants.storePhone}',
                        style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Email: ${AppConstants.storeEmail}',
                        style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice Date',
                        style: pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey,
                          fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(DateFormat('MMM d, yyyy').format(date),
                        style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      pw.Text(DateFormat('hh:mm a').format(date),
                        style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: order.status == 'delivered'
                              ? PdfColors.green
                              : PdfColors.orange,
                          borderRadius: pw.BorderRadius.circular(12)),
                        child: pw.Text(order.status.toUpperCase(),
                          style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.white)),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Bill To
              pw.Text('BILL TO',
                style: pw.TextStyle(
                  fontSize: 10, color: PdfColors.grey,
                  fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(order.deliveryAddress['name'] ?? '',
                      style: pw.TextStyle(
                        fontSize:   13,
                        fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text('Phone: ${order.deliveryAddress['phone'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${order.deliveryAddress['line1'] ?? ''}, '
                      '${order.deliveryAddress['city'] ?? ''} - '
                      '${order.deliveryAddress['pincode'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Items Table
              pw.Text('ORDER ITEMS',
                style: pw.TextStyle(
                  fontSize: 10, color: PdfColors.grey,
                  fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: const {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(1.5),
                  2: pw.FlexColumnWidth(1.5),
                  3: pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.green700),
                    children: [
                      _cell('ITEM', isHeader: true),
                      _cell('PRICE', isHeader: true, align: pw.TextAlign.right),
                      _cell('QTY', isHeader: true, align: pw.TextAlign.center),
                      _cell('TOTAL', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Items
                  ...order.items.map((item) => pw.TableRow(
                    children: [
                      _cell(item.productName),
                      _cell('${AppConstants.currency}${item.price.toStringAsFixed(2)}',
                        align: pw.TextAlign.right),
                      _cell('${item.quantity}', align: pw.TextAlign.center),
                      _cell('${AppConstants.currency}${item.subtotal.toStringAsFixed(2)}',
                        align: pw.TextAlign.right, bold: true),
                    ],
                  )).toList(),
                ],
              ),

              pw.SizedBox(height: 16),

              // Totals
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      _totalRow('Subtotal',
                        '${AppConstants.currency}${order.subtotal.toStringAsFixed(2)}'),
                      if (order.couponDiscount > 0)
                        _totalRow('Discount (${order.couponCode ?? ""})',
                          '-${AppConstants.currency}${order.couponDiscount.toStringAsFixed(2)}',
                          color: PdfColors.green),
                      _totalRow('Delivery Fee',
                        order.deliveryFee > 0
                            ? '${AppConstants.currency}${order.deliveryFee.toStringAsFixed(2)}'
                            : 'FREE'),
                      _totalRow('Tax',
                        '${AppConstants.currency}${order.tax.toStringAsFixed(2)}'),
                      pw.Divider(),
                      _totalRow('TOTAL',
                        '${AppConstants.currency}${order.totalAmount.toStringAsFixed(2)}',
                        bold: true, large: true),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // Payment Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Row(
                  children: [
                    pw.Text('Payment Method: ',
                      style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text(order.paymentMethod.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('Thank you for shopping with us!',
                  style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700)),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  '${AppConstants.storeName} - Fresh products delivered to your door',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text('For support: ${AppConstants.storeEmail}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _cell(String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize:   isHeader ? 10 : 11,
          color:      isHeader ? PdfColors.white : PdfColors.black,
          fontWeight: (isHeader || bold) ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value,
    {bool bold = false, bool large = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
            style: pw.TextStyle(
              fontSize: large ? 14 : 11,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
            style: pw.TextStyle(
              fontSize: large ? 16 : 11,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? (large ? PdfColors.green700 : PdfColors.black))),
        ],
      ),
    );
  }

  // Save PDF and share
  Future<void> downloadInvoice(OrderModel order) async {
    final pdf      = await generateInvoice(order);
    final bytes    = await pdf.save();
    final dir      = await getTemporaryDirectory();
    final fileName = 'Invoice_${order.orderNumber}.pdf';
    final file     = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Share the PDF
    await Share.shareXFiles(
      [XFile(file.path)],
      text:    'Invoice for Order #${order.orderNumber}',
      subject: '${AppConstants.storeName} - Invoice',
    );
  }

  // Print PDF
  Future<void> printInvoice(OrderModel order) async {
    final pdf = await generateInvoice(order);
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  // Preview PDF
  Future<void> previewInvoice(OrderModel order) async {
    final pdf = await generateInvoice(order);
    await Printing.sharePdf(
      bytes:    await pdf.save(),
      filename: 'Invoice_${order.orderNumber}.pdf',
    );
  }
}

