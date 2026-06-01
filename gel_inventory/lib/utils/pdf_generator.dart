import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import 'currency_format.dart';

Future<void> printInvoice({
  required Invoice invoice,
  required Client client,
  required List<InvoiceItem> items,
  required Map<String, Product> productsById,
}) async {
  final doc = pw.Document();
  final dateFmt = DateFormat('MMM dd, yyyy');

  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Text("GEL's Inventory",
            style: pw.TextStyle(
                fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Invoice ${invoice.displayNumber}'),
        pw.Text('Date: ${dateFmt.format(invoice.invoiceDate)}'),
        pw.Divider(),

        // Client info
        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(client.name),
        if (client.address != null) pw.Text(client.address!),
        pw.SizedBox(height: 12),

        // Items table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            _headerRow(['Product', 'Unit', 'Qty', 'Subtotal']),
            ...items.map((item) {
              final product = productsById[item.productId];
              return _dataRow([
                product?.name ?? item.productId,
                item.unitType,
                '${item.quantity}',
                formatCurrency(item.subtotal),
              ]);
            }),
          ],
        ),

        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Total: ${formatCurrency(invoice.totalAmount)}',
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  ));

  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

// ── Order Summary PDF ─────────────────────────────────────────────────────────

class OrderSummaryRow {
  final String productName;
  final int totalPieces;
  final int piecesPerBox;
  final double totalAmount;

  const OrderSummaryRow({
    required this.productName,
    required this.totalPieces,
    required this.piecesPerBox,
    required this.totalAmount,
  });

  int get boxes => totalPieces ~/ piecesPerBox;
  int get remainingPieces => totalPieces % piecesPerBox;
}

Future<void> printOrderSummary({
  required DateTime date,
  required List<OrderSummaryRow> rows,
}) async {
  final doc = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');
  final grandTotal = rows.fold(0.0, (s, r) => s + r.totalAmount);

  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("GEL's Inventory",
            style:
                pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Layout — ${dateFmt.format(date)}'),
        pw.Divider(),
        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FlexColumnWidth(5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            _headerRow(['Product', 'Boxes', 'Pieces']),
            ...rows.map((r) => _dataRow([
                  r.productName,
                  r.boxes > 0 ? '${r.boxes}' : '',
                  r.remainingPieces > 0 ? '${r.remainingPieces}' : '',
                ])),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Grand Total: ${formatCurrency(grandTotal)}',
            style: pw.TextStyle(
                fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  ));

  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

pw.TableRow _headerRow(List<String> cells) => pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ))
          .toList(),
    );

pw.TableRow _dataRow(List<String> cells) => pw.TableRow(
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c),
              ))
          .toList(),
    );
