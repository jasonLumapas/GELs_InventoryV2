import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';

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
    marginBottom: 45,
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
  final tsBusinessAddress = pw.TextStyle(font: font,     fontSize: 12.0);
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
          pw.Text("Purok Tambis, Curvada", style: tsBusinessAddress),
          pw.Text("San Remigio, Cebu, Philippines 6011", style: tsBusinessAddress),
          pw.Text("Tel. (032) 316-7836 / 0936-9445027", style: tsBusinessAddress),
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
    final discountAmt = item.isFree ? 0.0 : (originalAmt - item.subtotal);
    final showDiscount = !item.isFree && discountAmt > 0.01;

    itemWidgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
                width: descW, child: pw.Text(name, style: tsDesc)),
            pw.SizedBox(width: qtyW, child: rAlignAmt(qtyStr)),
            // Free items: show FREE in price, blank total
            pw.SizedBox(
                width: priceW,
                child: item.isFree
                    ? pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('FREE', style: tsAmt))
                    : rAlignAmt(_n(unitPrice))),
            pw.SizedBox(
              width: totalW,
              child: item.isFree
                  ? pw.SizedBox()
                  : pw.Column(
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
        pw.SizedBox(height: 4),
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

  await Printing.layoutPdf(
    onLayout: (_) => doc.save(),
    format: pageFormat,
  );
}

// ── Invoice List PDF ─────────────────────────────────────────────────────────

class InvoiceListItem {
  final String invoiceNumber;
  final String clientName;
  final DateTime date;
  final double amount;

  const InvoiceListItem({
    required this.invoiceNumber,
    required this.clientName,
    required this.date,
    required this.amount,
  });
}

Future<void> printInvoiceList({
  required String periodLabel,
  required List<InvoiceListItem> items,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMM dd, yyyy');
  final numFmt  = NumberFormat('#,##0.00');
  final grandTotal = items.fold(0.0, (s, i) => s + i.amount);

  final pageFormat = PdfPageFormat.letter.copyWith(
    marginTop: 40, marginBottom: 40,
    marginLeft: 40, marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final detailW = usableW * 0.70;
  final amtW    = usableW * 0.30;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs = 11.0;

  pw.TextStyle ts({bool bold = false}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

  String phpFmt(double v) => 'Php ${numFmt.format(v)}';

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      // Period label
      pw.Text(periodLabel, style: ts(bold: true)),
      pw.SizedBox(height: 12),

      // Column headers
      pw.Row(children: [
        pw.SizedBox(
            width: detailW,
            child: pw.Text('Invoice Details', style: ts(bold: true))),
        pw.SizedBox(
            width: amtW,
            child: pw.Text('Amount',
                style: ts(bold: true),
                textAlign: pw.TextAlign.right)),
      ]),
      pw.Divider(height: 6, thickness: 0.5),

      // Invoice rows with separators
      for (int i = 0; i < items.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(items[i].invoiceNumber, style: ts()),
              pw.Text(items[i].clientName, style: ts()),
              pw.Row(children: [
                pw.SizedBox(
                    width: detailW,
                    child: pw.Text(
                        dateFmt.format(items[i].date), style: ts())),
                pw.SizedBox(
                    width: amtW,
                    child: pw.Text(phpFmt(items[i].amount),
                        style: ts(),
                        textAlign: pw.TextAlign.right)),
              ]),
            ],
          ),
        ),
        if (i < items.length - 1)
          pw.Divider(height: 1, thickness: 0.3),
      ],

      pw.Divider(height: 8, thickness: 0.5),
      pw.SizedBox(height: 8),

      // Grand total
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Grand Total: ${phpFmt(grandTotal)}',
            style: ts(bold: true)),
      ),
    ],
  ));

  final bytes = await doc.save();
  final home  = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ?? '.';
  await File('$home\\Desktop\\invoice_list_${DateTime.now().millisecondsSinceEpoch}.pdf')
      .writeAsBytes(bytes);
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
  final doc      = pw.Document();
  final dateFmt  = DateFormat('MMMM dd, yyyy');
  final numFmt   = NumberFormat('#,##0.00');
  final grandTotal = rows.fold(0.0, (s, r) => s + r.totalAmount);

  final pageFormat = PdfPageFormat.letter.copyWith(
    marginTop: 40,
    marginBottom: 40,
    marginLeft: 40,
    marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final prodW  = usableW * 0.60;
  final boxW   = usableW * 0.20;
  final pcsW   = usableW * 0.20;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs = 11.0;

  pw.TextStyle ts({bool bold = false}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

  pw.Widget col(String text, double width,
          {bool bold = false, bool right = false}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(
          text,
          style: ts(bold: bold),
          textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        ),
      );

  doc.addPage(pw.Page(
    pageFormat: pageFormat,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Date header
        pw.Text('Date: ${dateFmt.format(date)}', style: ts()),
        pw.SizedBox(height: 16),

        // Column headers
        pw.Row(children: [
          col('Products', prodW, bold: true),
          col('Boxes',  boxW,  bold: true, right: true),
          col('Pieces', pcsW,  bold: true, right: true),
        ]),
        pw.Divider(height: 6, thickness: 0.5),

        // Data rows with separators
        for (int i = 0; i < rows.length; i++) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(children: [
              col(rows[i].productName, prodW),
              col(rows[i].boxes > 0 ? '${rows[i].boxes}' : '',
                  boxW, right: true),
              col(rows[i].remainingPieces > 0
                      ? '${rows[i].remainingPieces}'
                      : '',
                  pcsW, right: true),
            ]),
          ),
          if (i < rows.length - 1)
            pw.Divider(height: 1, thickness: 0.3),
        ],

        pw.Divider(height: 12, thickness: 0.5),
        pw.SizedBox(height: 8),

        // Grand total
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Grand Total: Php ${numFmt.format(grandTotal)}',
            style: ts(bold: true),
          ),
        ),
      ],
    ),
  ));

  // Output to desktop file
  final bytes = await doc.save();
  final home  = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ?? '.';
  final tag   = DateFormat('yyyyMMdd').format(date);
  await File('$home\\Desktop\\layout_$tag.pdf').writeAsBytes(bytes);
}

// ── Van Stock History PDF ─────────────────────────────────────────────────────

class VanStockHistoryRow {
  final String productName;
  final String supplierName;
  final String type;       // 'out' | 'in'
  final int quantityPieces;
  final int piecesPerBox;
  final String? notes;
  final DateTime date;

  const VanStockHistoryRow({
    required this.productName,
    required this.supplierName,
    required this.type,
    required this.quantityPieces,
    required this.piecesPerBox,
    required this.date,
    this.notes,
  });

  int get boxes => quantityPieces ~/ piecesPerBox;
  int get pcs   => quantityPieces % piecesPerBox;
  bool get isOut => type == 'out';
}

Future<void> printVanStockHistory({
  required DateTime date,
  required List<VanStockHistoryRow> rows,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');
  final timeFmt = DateFormat('HH:mm');

  final pageFormat = PdfPageFormat.letter.copyWith(
    marginTop: 40, marginBottom: 40,
    marginLeft: 40, marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final supW  = usableW * 0.18;
  final prodW = usableW * 0.30;
  final typeW = usableW * 0.10;
  final qtyW  = usableW * 0.16;
  final timeW = usableW * 0.12;
  final noteW = usableW * 0.14;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs = 10.0;

  pw.TextStyle ts({bool bold = false}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

  pw.Widget cell(String text, double width,
          {bool bold = false, bool right = false}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(text,
            style: ts(bold: bold),
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left),
      );

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      pw.Text('Van Stock History — ${dateFmt.format(date)}',
          style: ts(bold: true)),
      pw.SizedBox(height: 10),

      // Column headers
      pw.Row(children: [
        cell('Supplier', supW, bold: true),
        cell('Product',  prodW, bold: true),
        cell('Type',     typeW, bold: true),
        cell('Qty',      qtyW,  bold: true, right: true),
        cell('Time',     timeW, bold: true, right: true),
        cell('Notes',    noteW, bold: true),
      ]),
      pw.Divider(height: 6, thickness: 0.5),

      // Data rows
      for (int i = 0; i < rows.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(children: [
            cell(rows[i].supplierName, supW),
            cell(rows[i].productName,  prodW),
            cell(rows[i].isOut ? 'OUT' : 'IN', typeW,
                bold: true),
            cell(
              rows[i].boxes > 0
                  ? '${rows[i].boxes} box + ${rows[i].pcs} pcs'
                  : '${rows[i].pcs} pcs',
              qtyW, right: true),
            cell(timeFmt.format(rows[i].date), timeW, right: true),
            cell(rows[i].notes ?? '', noteW),
          ]),
        ),
        if (i < rows.length - 1) pw.Divider(height: 1, thickness: 0.3),
      ],
    ],
  ));

  final bytes = await doc.save();
  final home  = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ?? '.';
  final tag   = DateFormat('yyyyMMdd').format(date);
  await File('$home\\Desktop\\van_history_$tag.pdf').writeAsBytes(bytes);
}

// ── Loading Report PDF ────────────────────────────────────────────────────────

class LoadingReportRow {
  final String productName;
  final int piecesPerBox;
  final int loadedPieces;
  final int returnedPieces;

  const LoadingReportRow({
    required this.productName,
    required this.piecesPerBox,
    required this.loadedPieces,
    required this.returnedPieces,
  });

  int get soldPieces => (loadedPieces - returnedPieces).clamp(0, 999999);

  String _fmt(int pcs) {
    final b = pcs ~/ piecesPerBox;
    final p = pcs % piecesPerBox;
    return '${b > 0 ? '$b box${b == 1 ? '' : 'es'}' : ''}'
        '${b > 0 && p > 0 ? ' + ' : ''}${p > 0 ? '$p pcs' : ''}'
        .trim()
        .let((s) => s.isEmpty ? '0' : s);
  }

  String get loadedFmt   => _fmt(loadedPieces);
  String get returnedFmt => _fmt(returnedPieces);
  String get soldFmt     => _fmt(soldPieces);
}

extension _StringExt on String {
  String let(String Function(String) fn) => fn(this);
}

Future<void> printLoadingReport({
  required String   areaName,
  required DateTime loadingDate,
  required DateTime returnDate,
  required List<LoadingReportRow> rows,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');

  final pageFormat = PdfPageFormat.letter.copyWith(
    marginTop: 36, marginBottom: 36,
    marginLeft: 40, marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final itemW = usableW * 0.40;
  final colW  = usableW * 0.20;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs = 10.5;

  pw.TextStyle ts({bool bold = false}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

  pw.Widget col(String text, double width,
          {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(text,
            style: ts(bold: bold), textAlign: align),
      );

  // Total sold pieces across all products
  int totalSoldPieces = 0;
  for (final r in rows) { totalSoldPieces += r.soldPieces; }

  // Build a combined sold display using average ppb (all pieces, no box format for total)
  String totalSoldLabel = '$totalSoldPieces pcs';

  doc.addPage(pw.Page(
    pageFormat: pageFormat,
    build: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Report header
        pw.Text('Loading Report', style: ts(bold: true)),
        pw.SizedBox(height: 6),
        pw.Text('Area:          $areaName',   style: ts()),
        pw.Text('Loading Date:  ${dateFmt.format(loadingDate)}', style: ts()),
        pw.Text('Return Date:   ${dateFmt.format(returnDate)}',  style: ts()),
        pw.SizedBox(height: 12),

        // Column headers
        pw.Row(children: [
          col('ITEM',    itemW, bold: true),
          col('Loading', colW,  bold: true, align: pw.TextAlign.center),
          col('Return',  colW,  bold: true, align: pw.TextAlign.center),
          col('Sold',    colW,  bold: true, align: pw.TextAlign.center),
        ]),
        pw.Divider(height: 6, thickness: 0.5),

        // Data rows
        for (int i = 0; i < rows.length; i++) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(children: [
              col(rows[i].productName, itemW),
              col(rows[i].loadedFmt,   colW, align: pw.TextAlign.center),
              col(rows[i].returnedFmt, colW, align: pw.TextAlign.center),
              col(rows[i].soldFmt,     colW, align: pw.TextAlign.center),
            ]),
          ),
          if (i < rows.length - 1) pw.Divider(height: 1, thickness: 0.2),
        ],

        // Grand total
        pw.Divider(height: 8, thickness: 0.5),
        pw.Row(children: [
          col('Grand Total', itemW, bold: true),
          col('', colW),
          col('', colW),
          col(totalSoldLabel, colW, bold: true, align: pw.TextAlign.center),
        ]),
      ],
    ),
  ));

  final bytes = await doc.save();
  final home  = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ?? '.';
  final tag   = DateFormat('yyyyMMdd').format(returnDate);
  await File('$home\\Desktop\\loading_report_$tag.pdf').writeAsBytes(bytes);
}

// ── Van Loading / Stocks Return PDF ──────────────────────────────────────────

class VanTransactionPrintRow {
  final String productName;
  final String areaId;
  final String areaName;
  final int quantityPieces;
  final int piecesPerBox;
  final double sellingPrice;

  const VanTransactionPrintRow({
    required this.productName,
    required this.areaId,
    required this.areaName,
    required this.quantityPieces,
    required this.piecesPerBox,
    required this.sellingPrice,
  });

  int get boxes => quantityPieces ~/ piecesPerBox;
  int get pcs   => quantityPieces % piecesPerBox;
  double get amount => quantityPieces * sellingPrice;
}

Future<void> printVanTransactions({
  required DateTime date,
  required String title,
  required List<VanTransactionPrintRow> rows,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');
  final numFmt  = NumberFormat('#,##0.00');

  final pageFormat = PdfPageFormat.letter.copyWith(
    marginTop: 36, marginBottom: 36,
    marginLeft: 40, marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final prodW   = usableW * 0.52;
  final boxW    = usableW * 0.16;
  final pcsW    = usableW * 0.16;
  final amtW    = usableW * 0.16;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs = 10.0;

  pw.TextStyle ts({bool bold = false}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);

  pw.Widget col(String text, double width,
          {bool bold = false, bool right = false}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(text,
            style: ts(bold: bold),
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left),
      );

  String php(double v) => 'Php ${numFmt.format(v)}';

  // Group by areaId preserving insertion order
  final grouped = <String, List<VanTransactionPrintRow>>{};
  for (final r in rows) {
    grouped.putIfAbsent(r.areaId, () => []).add(r);
  }

  // First area shown in document header (multi-area prints label each group separately)
  final firstAreaName = grouped.entries.first.value.first.areaName;

  final widgets = <pw.Widget>[
    pw.Text('$title - ${dateFmt.format(date)}', style: ts(bold: true)),
    pw.SizedBox(height: 10),

    // Area line (document-level, above crew lines)
    pw.Text(
      'Area: ${grouped.length == 1 ? firstAreaName : "Multiple Areas"}',
      style: ts(bold: true),
    ),
    pw.SizedBox(height: 12),

    // Crew lines with spacing
    pw.Text('Driver:  ___________________________________', style: ts()),
    pw.SizedBox(height: 8),
    pw.Text('Agent:   ___________________________________', style: ts()),
    pw.SizedBox(height: 8),
    pw.Text('Junior:  ___________________________________', style: ts()),
    pw.SizedBox(height: 16),
  ];

  double grandTotal = 0;

  for (final entry in grouped.entries) {
    final areaName = entry.value.first.areaName;
    final areaRows = entry.value;
    final subtotal = areaRows.fold(0.0, (s, r) => s + r.amount);
    grandTotal += subtotal;

    // Per-group area header — only when multiple areas are present
    if (grouped.length > 1) {
      widgets.add(pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Area: $areaName', style: ts(bold: true)),
          pw.Text('Date: ${dateFmt.format(date)}', style: ts()),
        ],
      ));
    }
    widgets.add(pw.Divider(height: 4, thickness: 0.5));

    // Column headers
    widgets.add(pw.Row(children: [
      col('Product', prodW, bold: true),
      col('Boxes',   boxW,  bold: true, right: true),
      col('Pcs',     pcsW,  bold: true, right: true),
      col('Amount',  amtW,  bold: true, right: true),
    ]));
    widgets.add(pw.Divider(height: 3, thickness: 0.3));
    widgets.add(pw.SizedBox(height: 6));

    // Rows
    for (int i = 0; i < areaRows.length; i++) {
      final r = areaRows[i];
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(children: [
          col(r.productName, prodW),
          col(r.boxes > 0 ? '${r.boxes}' : '', boxW, right: true),
          col(r.pcs   > 0 ? '${r.pcs}'   : '', pcsW, right: true),
          col(numFmt.format(r.amount),          amtW, right: true),
        ]),
      ));
      if (i < areaRows.length - 1) {
        widgets.add(pw.Divider(height: 1, thickness: 0.2));
      }
    }

    // Subtotal — only shown when multiple area groups are printed
    widgets.add(pw.Divider(height: 4, thickness: 0.5));
    if (grouped.length > 1) {
      widgets.add(pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Subtotal: ${php(subtotal)}', style: ts(bold: true)),
      ));
    }
    widgets.add(pw.SizedBox(height: 14));
  }

  // Grand total
  widgets.add(pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Text('Grand Total: ${php(grandTotal)}',
        style: pw.TextStyle(font: fontBold, fontSize: fs + 2)),
  ));

  doc.addPage(pw.MultiPage(pageFormat: pageFormat, build: (_) => widgets));

  final bytes = await doc.save();
  final home  = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ?? '.';
  final tag   = DateFormat('yyyyMMdd').format(date);
  final label = title.toLowerCase().replaceAll(' ', '_');
  await File('$home\\Desktop\\${label}_$tag.pdf').writeAsBytes(bytes);
}

