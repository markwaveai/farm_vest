import 'dart:io';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/investor/models/unit_response.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceGenerator {
  static Future<String> generateInvoice(Order order) async {
    final pdf = pw.Document();

    /// ---------- BUSINESS LOGIC ----------
    const double halfUnitCost =
      FormatUtils.halfUnitCost;// cost per 0.5 unit (1 buffalo + 1 calf)
    const double cpfPerUnit = FormatUtils.cpfPerUnit; // CPF per half unit

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
    // final logoImage = pw.MemoryImage(
    //   (await rootBundle.load(
    //     "assets/images/buffalo4.jpeg",
    //   )).buffer.asUint8List(),
    // );

    final bgSvg = pw.SvgImage(
      svg: await rootBundle.loadString('assets/images/invoice_background.svg'),
    );

    /// ---------- PDF PAGE ----------
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(25),
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
                      // pw.Image(logoImage, height: 70),
                      // pw.SizedBox(height: 10),
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
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
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
                        "Breed : ${order.breedId}\nBuffalos: ${(units * 2).ceil()}\nCalves: ${(units * 2).ceil()}",
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
                        pw.SizedBox(height: 5),
                        if (withCpf && cpfAmount > 0)
                          _priceRow("CPF ", FormatUtils.formatAmount(cpfAmount)),
                        pw.SizedBox(height: 5),
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


