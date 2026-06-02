import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import 'currency_format.dart';

final _rcptFmt = NumberFormat('#,##0.00');
String _n(double v) => _rcptFmt.format(v);

pw.Font? _loadFont(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    return pw.Font.ttf(bytes.buffer.asByteData());
  } catch (_) {
    return null;
  }
}

// ── Delivery Receipt PDF (dot-matrix, 3.75" × 11" continuous) ────────────────

Future<void> printInvoice({
  required Invoice invoice,
  required Client client,
  required List<InvoiceItem> items,
  required Map<String, Product> productsById,
}) async {
  final doc = pw.Document();
  final dateFmt = DateFormat('MM/dd/yyyy');
  final font            = _loadFont('C:\\Windows\\Fonts\\arial.ttf')    ?? pw.Font.helvetica();
  final fontBold        = _loadFont('C:\\Windows\\Fonts\\arialbd.ttf')  ?? pw.Font.helveticaBold();
  final fontNarrowBold    = _loadFont('C:\\Windows\\Fonts\\ARIALNB.TTF')  ??
      _loadFont('C:\\Windows\\Fonts\\arialnb.ttf') ?? fontBold;
  final fontTahoma        = _loadFont('C:\\Windows\\Fonts\\tahomabd.ttf') ?? fontBold;
  const double fs         = 10.0; // general header text
  const double fsBusiness = 14.0; // company name
  const double cm = 28.35; // 1 cm in PDF points

  final pageFormat = PdfPageFormat(
    4.0 * PdfPageFormat.inch,
    11.0 * PdfPageFormat.inch,
    marginTop: 10,
    marginBottom: 20,
    marginLeft: 14,
    marginRight: 8,
  );
  final usableW = pageFormat.availableWidth;
  final descW  = usableW * 0.38;
  final qtyW   = usableW * 0.20;
  final priceW = usableW * 0.21;
  final totalW = usableW * 0.21;

  pw.TextStyle ts(bool bold) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

  final tsBusiness  = pw.TextStyle(font: fontBold,      fontSize: fsBusiness);
  final tsDesc      = pw.TextStyle(font: fontNarrowBold, fontSize: 11.5);
  final tsAmt       = pw.TextStyle(font: fontBold,      fontSize: 10.5);
  final tsDelivered     = pw.TextStyle(font: font,     fontSize: 12.0);
  final tsDeliveredBold = pw.TextStyle(font: fontBold, fontSize: 12.0);
  final tsSmall     = pw.TextStyle(font: font,           fontSize: fs - 2);

  pw.Widget rAlign(String text, {bool bold = false}) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(text, style: ts(bold)),
      );

  pw.Widget rAlignAmt(String text) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(text, style: tsAmt),
      );

  // Header repeated on every page
  pw.Widget pageHeader(pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("GEL'S CONSUMER GOODS TRADING", style: tsBusiness),
          pw.Text("Purok Tambis, Curyada", style: ts(false)),
          pw.Text("San Remigio, Cebu, Philippines 6011", style: ts(false)),
          pw.Text("Tel. (032) 316-7836 / 0936-9445027", style: ts(false)),
          pw.SizedBox(height: 1 * cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("DELIVERY RECEIPT", style: ts(true)),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(invoice.displayNumber, style: tsDeliveredBold),
                  pw.SizedBox(height: 0.4 * cm),
                  pw.Text("Date: ${dateFmt.format(invoice.invoiceDate)}", style: tsDelivered),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 1 * cm),
          pw.RichText(text: pw.TextSpan(
            text: "Delivered to: ", style: tsDelivered,
            children: [pw.TextSpan(text: client.name, style: tsDeliveredBold)],
          )),
          if (client.address != null && client.address!.isNotEmpty)
            pw.RichText(text: pw.TextSpan(
              text: "Address: ", style: tsDelivered,
              children: [pw.TextSpan(text: client.address!, style: tsDeliveredBold)],
            )),
          pw.Text("TERMS: __________", style: tsDelivered),
          pw.SizedBox(height: 0.5 * cm),
          pw.Row(
            children: [
              pw.SizedBox(
                  width: descW,
                  child: pw.Text("Description", style: ts(true))),
              pw.SizedBox(width: qtyW, child: rAlign("Qty", bold: true)),
              pw.SizedBox(width: priceW, child: rAlign("Price", bold: true)),
              pw.SizedBox(width: totalW, child: rAlign("Total", bold: true)),
            ],
          ),
          pw.Divider(height: 3, thickness: 0.5),
        ],
      );

  // Item rows
  final itemWidgets = <pw.Widget>[];
  for (final item in items) {
    final product = productsById[item.productId];
    final ppb = product?.piecesPerBox ?? 1;
    final name = product?.name ?? item.productId;

    final String qtyStr;
    final double unitPrice;
    if (item.unitType == 'box') {
      final boxes = item.quantity ~/ ppb;
      qtyStr = '$boxes ${boxes == 1 ? "case" : "cases"}';
      unitPrice = item.pricePerPiece * ppb;
    } else {
      qtyStr = '${item.quantity} pcs';
      unitPrice = item.pricePerPiece;
    }

    final originalAmt = item.quantity * item.pricePerPiece;
    final discountAmt = item.isFree ? originalAmt : (originalAmt - item.subtotal);
    final showDiscount = discountAmt > 0.01;

    itemWidgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
                width: descW, child: pw.Text(name, style: tsDesc)),
            pw.SizedBox(width: qtyW, child: rAlignAmt(qtyStr)),
            pw.SizedBox(width: priceW, child: rAlignAmt(_n(unitPrice))),
            pw.SizedBox(
              width: totalW,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(_n(originalAmt), style: tsAmt),
                  if (showDiscount)
                    pw.Text('(${_n(discountAmt)})', style: tsAmt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Total — appended inline after items
  final halfW = usableW / 2;
  final totalWidgets = <pw.Widget>[
    pw.SizedBox(height: 4),
    pw.Divider(height: 4, thickness: 0.5),
    pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text("Total = ${_n(invoice.totalAmount)}",
          style: pw.TextStyle(font: fontTahoma, fontSize: 12.0)),
    ),
  ];

  // Footer — signature just above page number on last page; page number only on others
  final tsPage = pw.TextStyle(font: font, fontSize: 10.0);

  pw.Widget pageFooter(pw.Context ctx) {
    final pageNum = pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Text(
        "Page ${ctx.pageNumber}/${ctx.pagesCount}",
        style: tsPage,
      ),
    );

    if (ctx.pageNumber < ctx.pagesCount) return pageNum;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Received the above goods and services in good order and condition.",
            style: tsSmall,
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: halfW,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("By: ", style: tsSmall),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("_____________________", style: tsSmall),
                        pw.Text("Authorized signature", style: tsSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(
              width: halfW,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("____________________________", style: tsSmall),
                  pw.Text("Customer signature over printed name", style: tsSmall),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pageNum,
      ],
    );
  }

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    header: pageHeader,
    footer: pageFooter,
    build: (ctx) => [...itemWidgets, ...totalWidgets],
  ));

  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

// ── Layout / Order Summary PDF ────────────────────────────────────────────────

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
    pageFormat: PdfPageFormat.letter.copyWith(marginTop: 36),
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
