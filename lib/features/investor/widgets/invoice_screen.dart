import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:farm_vest/features/investor/models/unit_response.dart';
import '../../../../core/theme/app_theme.dart';

class InvoiceScreen extends StatelessWidget {
  final Order order;

  const InvoiceScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    /// ---------- BUSINESS LOGIC ----------
    const double halfUnitCost =
        175000; // cost per 0.5 unit (1 buffalo + 1 calf)
    const double cpfPerUnit = 13000; // CPF per half unit

    double units = (order.numUnits ?? 0).toDouble(); // exact units entered

    // Subtotal = units × 2 halves × halfUnitCost
    double subtotalAmount = units * 2 * halfUnitCost;

    // CPF calculation
    int totalHalves = (units * 2).ceil(); // for CPF counting
    int freeCpf = (totalHalves / 2).floor(); // 1 CPF free per 1 unit (2 halves)
    int paidCpf = totalHalves - freeCpf; // remaining halves charged CPF
    double cpfAmount = paidCpf * cpfPerUnit;
    double cpfDiscountAmount = freeCpf * cpfPerUnit;

    // Total invoice amount
    double totalAmount = subtotalAmount + cpfAmount;
    final bool withCpf = order.withCpf ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _downloadInvoice(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: SvgPicture.asset(
                  'assets/images/invoice_background.svg',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
          ),

          // Foreground Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(
                      0.9,
                    ), // Slight transparency for glass effect if desired, or keep solid
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo and Company Name
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/buffalo4.jpeg",
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Markwave India Private Limited",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "CIN: U62013TS2025PTC201549",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        "INVOICE",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(context, "Invoice No", order.id ?? "N/A"),
                      _buildInfoRow(
                        context,
                        "Order Date",
                        formatOrderDate(
                          order.approvalDate != null
                              ? DateTime.tryParse(order.approvalDate!)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Addresses
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildAddressBlock(
                        context,
                        "Invoice Address",
                        "Kurnool, Andhra Pradesh",
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildAddressBlock(
                        context,
                        "Shipping Address",
                        "PSR Prime Towers, DLF, Hyderabad, Telangana, 500081",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Table
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Description",
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Qty",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Unit Price",
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Amount",
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Items
                      _buildTableItem(
                        context,
                        "Breed: ${order.breedId}\nBuffalos: ${(units * 2).ceil()}\nCalves: ${(units * 2).ceil()}",
                        "$units",
                        FormatUtils.formatAmount(halfUnitCost * 2),
                        FormatUtils.formatAmount(subtotalAmount),
                      ),
                      if (withCpf && cpfAmount > 0)
                        _buildTableItem(
                          context,
                          "CPF Amount",
                          "$paidCpf",
                          FormatUtils.formatAmount(cpfPerUnit),
                          FormatUtils.formatAmount(cpfAmount),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        context,
                        "Subtotal",
                        FormatUtils.formatAmount(subtotalAmount),
                      ),
                      if (withCpf && cpfAmount > 0)
                        _buildSummaryRow(
                          context,
                          "CPF",
                          FormatUtils.formatAmount(cpfAmount),
                        ),
                      if (withCpf && cpfDiscountAmount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CPF Discount",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Row(
                                children: [
                                  Text(
                                    FormatUtils.formatAmount(cpfDiscountAmount),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.red,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    FormatUtils.formatAmount(0),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      _buildSummaryRow(
                        context,
                        "Total",
                        FormatUtils.formatAmount(totalAmount),
                        isBold: true,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Terms
                Text(
                  "Terms & Conditions",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "1. This purchase is non-refundable.\n"
                  "2. Once the order is confirmed, no cancellation or refund will be provided.\n"
                  "3. The company is not responsible for delays caused by unforeseen circumstances.\n"
                  "4. This invoice is generated electronically and does not require a signature.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Text(
                    "405, 4th Floor, PSR Prime Tower, Gachibowli, Telangana - 500032",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBlock(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTableItem(
    BuildContext context,
    String desc,
    String qty,
    String price,
    String amount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(desc, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Text(
              qty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              price,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 18 : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      // Show loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating Invoice...')));

      final path = await InvoiceGenerator.generateInvoice(order);

      // Share/Open the file
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await Share.shareXFiles([
          XFile(path),
        ], text: 'Invoice for Order #${order.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating invoice: $e')));
      }
    }
  }
}

class FormatUtils {
  static String formatAmount(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }
}

class InvoiceGenerator {
  static Future<String> generateInvoice(Order order) async {
    final pdf = pw.Document();

    /// ---------- BUSINESS LOGIC ----------
    const double halfUnitCost =
        175000; // cost per 0.5 unit (1 buffalo + 1 calf)
    const double cpfPerUnit = 13000; // CPF per half unit

    double units = (order.numUnits ?? 0).toDouble(); // exact units entered

    // Subtotal = units × 2 halves × halfUnitCost
    double subtotalAmount = units * 2 * halfUnitCost;

    // CPF calculation
    int totalHalves = (units * 2).ceil(); // for CPF counting
    int freeCpf = (totalHalves / 2).floor(); // 1 CPF free per 1 unit (2 halves)
    int paidCpf = totalHalves - freeCpf; // remaining halves charged CPF
    double cpfAmount = paidCpf * cpfPerUnit;
    double cpfDiscountAmount = freeCpf * cpfPerUnit;

    // Total invoice amount
    double totalAmount = subtotalAmount + cpfAmount;
    final bool withCpf = order.withCpf ?? false;

    /// ---------- ASSETS ----------
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(
        "assets/images/buffalo4.jpeg",
      )).buffer.asUint8List(),
    );

    final bgSvg = pw.SvgImage(
      svg: await rootBundle.loadString('assets/images/invoice_background.svg'),
    );

    /// ---------- PDF PAGE ----------
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Opacity(opacity: 0.08, child: bgSvg),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  /// HEADER
                  pw.Column(
                    children: [
                      pw.Image(logoImage, height: 70),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Markwave India Private Limited",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "CIN: U62013TS2025PTC201549",
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Divider(height: 30),

                  /// TITLE
                  pw.Center(
                    child: pw.Text(
                      "INVOICE",
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#673AB7"),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  /// INFO
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn("Invoice No", order.id ?? "N/A"),
                      _infoColumn(
                        "Order Date",
                        formatOrderDate(
                          order.approvalDate != null
                              ? DateTime.tryParse(order.approvalDate!)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  /// ADDRESS
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _addressBlock(
                        "Invoice Address",
                        "Kurnool, Andhra Pradesh",
                      ),
                      _addressBlock(
                        "Shipping Address",
                        "PSR Prime Towers, DLF, Hyderabad, Telangana, 500081",
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  /// TABLE
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#EEEEEE'),
                        ),
                        children: [
                          _tableHeader("Description"),
                          _tableHeader("Qty"),
                          _tableHeader("Unit Price"),
                          _tableHeader("Amount"),
                        ],
                      ),

                      /// BASE COST ROW
                      buildRow(
                        "Breed: ${order.breedId}\nBuffalos: ${(units * 2).ceil()}\nCalves: ${(units * 2).ceil()}",
                        "$units", // display exact units
                        FormatUtils.formatAmount(
                          halfUnitCost * 2,
                        ), // 1 unit price
                        FormatUtils.formatAmount(subtotalAmount),
                      ),

                      /// CPF ROW
                      if (withCpf && cpfAmount > 0)
                        buildRow(
                          "CPF Amount",
                          "$paidCpf",
                          FormatUtils.formatAmount(cpfPerUnit),
                          FormatUtils.formatAmount(cpfAmount),
                        ),
                    ],
                  ),
                  pw.SizedBox(height: 25),

                  /// SUMMARY
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _priceRow(
                          "Subtotal",
                          FormatUtils.formatAmount(subtotalAmount),
                        ),
                        if (withCpf && cpfAmount > 0)
                          _priceRow("CPF", FormatUtils.formatAmount(cpfAmount)),

                        // CPF Discount
                        if (withCpf && cpfDiscountAmount > 0)
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text("CPF Discount: "),
                              pw.SizedBox(width: 5),
                              pw.Text(
                                FormatUtils.formatAmount(cpfDiscountAmount),
                                style: pw.TextStyle(
                                  decoration: pw.TextDecoration.lineThrough,
                                  color: PdfColors.red,
                                ),
                              ),
                              pw.SizedBox(width: 5),
                              pw.Text(
                                FormatUtils.formatAmount(0),
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                        pw.Divider(),
                        _priceRow(
                          "Total",
                          FormatUtils.formatAmount(totalAmount),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  _termsAndConditions(),
                  pw.Spacer(),

                  /// FOOTER
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          "405, 4th Floor, PSR Prime Tower, Gachibowli, Telangana - 500032",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          "Page 1 of 1",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/invoice_${order.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// HELPERS
  static pw.Widget _tableHeader(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      textAlign: pw.TextAlign.center,
    ),
  );

  static pw.TableRow buildRow(
    String desc,
    String qty,
    String price,
    String total,
  ) => pw.TableRow(
    children: [
      _cell(desc),
      _cell(qty, center: true),
      _cell(price, center: true),
      _cell(total, center: true),
    ],
  );

  static pw.Widget _cell(String text, {bool center = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
    ),
  );

  static pw.Widget _priceRow(String label, String value, {bool bold = false}) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            "$label: ",
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      );

  static pw.Widget _termsAndConditions() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        "Terms & Conditions",
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        "1. This purchase is non-refundable.\n"
        "2. Once the order is confirmed, no cancellation or refund will be provided.\n"
        "3. The company is not responsible for delays caused by unforeseen circumstances.\n"
        "4. This invoice is generated electronically and does not require a signature.",
        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    ],
  );

  static pw.Widget _infoColumn(String label, String value) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(value),
    ],
  );

  static pw.Widget _addressBlock(String title, String value) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(value),
    ],
  );
}

/// DATE FORMAT
String formatOrderDate(DateTime? date) {
  if (date == null) return "";
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}
