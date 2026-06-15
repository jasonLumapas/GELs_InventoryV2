import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/services/printer_settings_service.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import '../models/purchase_order.dart';
import '../models/purchase_order_item.dart';
import '../models/supplier.dart';
import '../models/supplier_received_invoice.dart';
import '../models/supplier_received_invoice_item.dart';
import 'product_format.dart';

// ── Printer routing helper ────────────────────────────────────────────────────
// Shows the system print dialog so the user can confirm printer and page setup.
Future<void> _printWithSlot({
  required pw.Document doc,
  required PdfPageFormat format,
  required String slot,
}) async {
  await Printing.layoutPdf(
    onLayout: (_) => doc.save(),
    format: format,
  );
}

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

// ── Delivery Receipt PDF (4" × 11" continuous, multi-page) ────────────────────
// Non-last pages are full 11" sheets; the header repeats at the top of each and
// a "Page n/N" indicator is placed inline right after the last item — no gap.
// The last page is trimmed to its content height so the printer stops early
// and doesn't feed blank paper after the signature block.

Future<void> printInvoice({
  required Invoice invoice,
  required Client client,
  required List<InvoiceItem> items,
  required Map<String, Product> productsById,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MM/dd/yyyy');

  final font           = _loadFont('C:\\Windows\\Fonts\\arial.ttf')   ?? pw.Font.helvetica();
  final fontBold       = _loadFont('C:\\Windows\\Fonts\\arialbd.ttf') ?? pw.Font.helveticaBold();
  final fontNarrowBold = _loadFont('C:\\Windows\\Fonts\\ARIALNB.TTF') ??
      _loadFont('C:\\Windows\\Fonts\\arialnb.ttf') ?? fontBold;
  final fontTahoma     = _loadFont('C:\\Windows\\Fonts\\tahomabd.ttf') ?? fontBold;

  const double fs         = 10.0;
  const double fsBusiness = 14.0;
  const double cm         = 28.35;

  const double mTop   = 10.0;
  const double mBot   = 20.0;
  const double mLeft  = 14.0;
  const double mRight = 8.0;
  const double pageW  = 4.0 * PdfPageFormat.inch;

  final double usableW = pageW - mLeft - mRight;
  final double halfW   = usableW / 2;
  final double descW   = usableW * 0.38;
  final double qtyW    = usableW * 0.20;
  final double priceW  = usableW * 0.21;
  final double totalW  = usableW * 0.21;

  pw.TextStyle ts(bool bold) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);
  final tsBusiness      = pw.TextStyle(font: fontBold,       fontSize: fsBusiness);
  final tsBusinessAddr  = pw.TextStyle(font: font,           fontSize: 12.0);
  final tsDesc          = pw.TextStyle(font: fontNarrowBold, fontSize: 11.5);
  final tsAmt           = pw.TextStyle(font: fontBold,       fontSize: 10.5);
  final tsDelivered     = pw.TextStyle(font: font,           fontSize: 12.0);
  final tsDeliveredBold = pw.TextStyle(font: fontBold,       fontSize: 12.0);
  final tsSmall         = pw.TextStyle(font: font,           fontSize: fs - 2);
  final tsPage          = pw.TextStyle(font: font,           fontSize: fs);

  pw.Widget rAlign(String text, {bool bold = false}) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(text, style: ts(bold)),
      );
  pw.Widget rAlignAmt(String text) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(text, style: tsAmt),
      );

  // ── Header (called per page so each page gets a fresh widget instance) ───────
  pw.Widget pageHeader() => pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text("GEL'S CONSUMER GOODS TRADING",          style: tsBusiness),
      pw.Text("Purok Tambis, Curvada",                  style: tsBusinessAddr),
      pw.Text("San Remigio, Cebu, Philippines 6011",    style: tsBusinessAddr),
      pw.Text("Tel. (032) 316-7836 / 0936-9445027",    style: tsBusinessAddr),
      pw.SizedBox(height: 1 * cm),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("DELIVERY RECEIPT", style: ts(true)),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(invoice.displayNumber,                          style: tsDeliveredBold),
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
      pw.Row(children: [
        pw.SizedBox(width: descW,  child: pw.Text("Description", style: ts(true))),
        pw.SizedBox(width: qtyW,   child: rAlign("Qty",   bold: true)),
        pw.SizedBox(width: priceW, child: rAlign("Price", bold: true)),
        pw.SizedBox(width: totalW, child: rAlign("Total", bold: true)),
      ]),
      pw.Divider(height: 3, thickness: 0.5),
    ],
  );

  // ── Item height estimator ────────────────────────────────────────────────────
  // 22 pt = single-line row; 36 pt = two-line row (long name or discount).
  double itemH(InvoiceItem item) {
    final product = productsById[item.productId];
    final name = product != null
        ? '${product.name} x ${product.piecesPerBox}'
        : '';
    final orig = item.quantity * item.pricePerPiece;
    final twoLine = name.length > 20 ||
        (!item.isFree && (orig - item.subtotal) > 0.01);
    return twoLine ? 36.0 : 22.0;
  }

  // ── Item widgets ─────────────────────────────────────────────────────────────
  final itemWidgets = <pw.Widget>[];
  for (final item in items) {
    final product = productsById[item.productId];
    final ppb  = product?.piecesPerBox ?? 1;
    final name = product != null
        ? '${product.name} x ${product.piecesPerBox}'
        : item.productId;

    final String qtyStr;
    final double unitPrice;
    if (item.unitType == 'box') {
      final boxes = item.quantity ~/ ppb;
      qtyStr    = '$boxes ${boxes == 1 ? "case" : "cases"}';
      unitPrice = item.pricePerPiece * ppb;
    } else {
      qtyStr    = '${item.quantity} pcs';
      unitPrice = item.pricePerPiece;
    }

    final originalAmt  = item.quantity * item.pricePerPiece;
    final discountAmt  = item.isFree ? 0.0 : (originalAmt - item.subtotal);
    final showDiscount = !item.isFree && discountAmt > 0.01;

    itemWidgets.add(pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: descW,  child: pw.Text(name, style: tsDesc)),
          pw.SizedBox(width: qtyW,   child: rAlignAmt(qtyStr)),
          pw.SizedBox(width: priceW, child: item.isFree
              ? pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('FREE', style: tsAmt))
              : rAlignAmt(_n(unitPrice))),
          pw.SizedBox(width: totalW, child: item.isFree
              ? pw.SizedBox()
              : pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(_n(originalAmt), style: tsAmt),
                    if (showDiscount) pw.Text('(${_n(discountAmt)})', style: tsAmt),
                  ],
                )),
        ],
      ),
    ));
  }

  // ── Total section ────────────────────────────────────────────────────────────
  final itemCountLabel = '${items.length} item${items.length == 1 ? '' : 's'}';
  final totalSection = pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Divider(height: 4, thickness: 0.5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(itemCountLabel, style: tsSmall),
          pw.Text("Total = ${_n(invoice.totalAmount)}",
              style: pw.TextStyle(font: fontTahoma, fontSize: 12.0)),
        ],
      ),
    ],
  );

  // ── Signature block ───────────────────────────────────────────────────────────
  final signatureBlock = pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 10),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          "Received the above goods and\n services in good order and condition.",
          style: tsSmall,
          textAlign: pw.TextAlign.right,
        ),
      ),
      pw.SizedBox(height: 6),
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
                      pw.Text("Authorized signature",  style: tsSmall),
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
                pw.Text("____________________________",               style: tsSmall),
                pw.Text("Customer signature over printed name", style: tsSmall),
              ],
            ),
          ),
        ],
      ),
    ],
  );

  // ── Pagination ────────────────────────────────────────────────────────────────
  // Budget constants (all in pt).
  // kHeaderH:    conservative upper bound for the rendered header height.
  //              Keeps it above worst-case (long name + address that wraps).
  // kPageIndH:   space for the inline "Page n/N" on non-last pages.
  // kTotalSigH:  pagination budget for totalSection + sig + indicator on last page.
  // kSigFooterH: tighter estimate used when computing the push-down gap below.
  const double kHeaderH    = 270.0;
  const double kPageIndH   = 20.0;
  const double kTotalSigH  = 105.0;
  const double kSigFooterH = 95.0;  // totalSection~20 + sig~58 + indicator~16 + slack

  final stdFormat = PdfPageFormat(
    pageW, 11.0 * PdfPageFormat.inch,
    marginTop: mTop, marginBottom: mBot,
    marginLeft: mLeft, marginRight: mRight,
  );
  // Last page uses a smaller bottom margin so the signature + indicator
  // never overflow even when the Spacer collapses to near-zero.
  final lastFormat = PdfPageFormat(
    pageW, 11.0 * PdfPageFormat.inch,
    marginTop: mTop, marginBottom: 6.0,
    marginLeft: mLeft, marginRight: mRight,
  );
  final double availH      = stdFormat.height - mTop - mBot; // 762 pt
  final double kAvailItems = availH - kHeaderH - kPageIndH;  // 492 pt

  // Split item widgets into per-page buckets.
  final pageGroups = <List<pw.Widget>>[];
  var bucket  = <pw.Widget>[];
  double bucketH = 0.0;

  for (var i = 0; i < itemWidgets.length; i++) {
    final h = itemH(items[i]);
    if (bucketH + h > kAvailItems && bucket.isNotEmpty) {
      pageGroups.add(bucket);
      bucket  = [];
      bucketH = 0.0;
    }
    bucket.add(itemWidgets[i]);
    bucketH += h;
  }

  final lastBucketH = bucketH;
  pageGroups.add(bucket);
  if (pageGroups.isEmpty) pageGroups.add([]);

  // If the last bucket leaves no room for total+signature, overflow to new page.
  final lastFitsAll = lastBucketH + kTotalSigH <= kAvailItems;
  if (!lastFitsAll) pageGroups.add([]);

  final totalPages = pageGroups.length;

  // ── Render pages ──────────────────────────────────────────────────────────────
  // Pre-compute the push-down gap for the last page so the signature block
  // lands near the bottom without relying on pw.Spacer (which doesn't receive
  // tight height constraints from pw.Page in this pdf package version).
  final double lastAvailH  = lastFormat.height - mTop - 6.0; // marginBottom=6
  final double lastItemsH  = lastFitsAll ? lastBucketH : 0.0;
  final double sigGapH     =
      (lastAvailH - kHeaderH - lastItemsH - kSigFooterH).clamp(0.0, double.infinity);

  for (var i = 0; i < totalPages; i++) {
    final pgNum  = i + 1;
    final isLast = pgNum == totalPages;
    doc.addPage(pw.Page(
      pageFormat: isLast ? lastFormat : stdFormat,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(),
          ...pageGroups[i],
          if (isLast) ...[
            totalSection,
            pw.SizedBox(height: sigGapH),
            signatureBlock,
            if (totalPages > 1)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Center(
                  child: pw.Text("Page $pgNum/$totalPages", style: tsPage),
                ),
              ),
          ] else
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Center(
                child: pw.Text("Page $pgNum/$totalPages", style: tsPage),
              ),
            ),
        ],
      ),
    ));
  }

  await _printWithSlot(
    doc: doc, format: stdFormat, slot: PrinterSettingsService.invoice);
}

// ── Invoice List PDF ─────────────────────────────────────────────────────────

class InvoiceListItem {
  final String invoiceNumber;
  final String clientName;
  final DateTime date;
  final double amount;
  final String? notes;

  const InvoiceListItem({
    required this.invoiceNumber,
    required this.clientName,
    required this.date,
    required this.amount,
    this.notes,
  });
}

Future<void> printInvoiceList({
  required String periodLabel,
  required List<InvoiceListItem> items,
}) async {
  final doc    = pw.Document();
  final numFmt = NumberFormat('#,##0.00');
  final grandTotal = items.fold(0.0, (s, i) => s + i.amount);

  final pageFormat = PdfPageFormat.a4.copyWith(
    marginTop: 40, marginBottom: 40,
    marginLeft: 40, marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final invNoW  = usableW * 0.22;
  final clientW = usableW * 0.48;
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
            width: invNoW,
            child: pw.Text('Invoice #', style: ts(bold: true))),
        pw.SizedBox(
            width: clientW,
            child: pw.Text('Store', style: ts(bold: true))),
        pw.SizedBox(
            width: amtW,
            child: pw.Text('Amount',
                style: ts(bold: true),
                textAlign: pw.TextAlign.right)),
      ]),
      pw.Divider(height: 6, thickness: 0.5),

      // Invoice rows
      for (int i = 0; i < items.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                  width: invNoW,
                  child: pw.Text(items[i].invoiceNumber, style: ts())),
              pw.SizedBox(
                  width: clientW,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(items[i].clientName, style: ts()),
                      if (items[i].notes != null &&
                          items[i].notes!.trim().isNotEmpty)
                        pw.Text(items[i].notes!.trim(),
                            style: pw.TextStyle(
                                font: font, fontSize: fs - 2)),
                    ],
                  )),
              pw.SizedBox(
                  width: amtW,
                  child: pw.Text(phpFmt(items[i].amount),
                      style: ts(), textAlign: pw.TextAlign.right)),
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
            style: pw.TextStyle(
                font: fontBold, fontSize: 14)),
      ),
    ],
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.invoiceList);
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

  final pageFormat = PdfPageFormat.a4.copyWith(
    marginTop: 40,
    marginBottom: 40,
    marginLeft: 40,
    marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final prodW  = usableW * 0.46;
  final boxW   = usableW * 0.14;
  final pcsW   = usableW * 0.24;   // wider to fit "No. of pieces/packs"

  final font     = _loadFont('C:\\Windows\\Fonts\\arial.ttf')   ?? pw.Font.helvetica();
  final fontBold = _loadFont('C:\\Windows\\Fonts\\arialbd.ttf') ?? pw.Font.helveticaBold();
  const double fs     = 9.5;   // item font size
  const double fsHead = 10.5;  // header / label font size

  pw.TextStyle ts({bool bold = false, double? size}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: size ?? fs);

  pw.Widget col(String text, double width,
          {bool bold = false,
           pw.TextAlign align = pw.TextAlign.left,
           double? size}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(
          text,
          style: ts(bold: bold, size: size),
          textAlign: align,
        ),
      );

  pw.Widget signLine(String label) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(label, style: ts(size: fsHead)),
      );

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      // Layout date
      pw.Text('Layout: ${dateFmt.format(date)}',
          style: ts(bold: true, size: fsHead)),
      pw.SizedBox(height: 10),

      // Crew signature lines
      signLine('Driver:      _____________________________'),
      signLine('Junior 1:  ___________________________'),
      signLine('Junior 2:  ___________________________'),
      pw.SizedBox(height: 10),

      // Column headers
      pw.Row(children: [
        col('Product Description', prodW, bold: true, size: fsHead),
        col('No. of case',         boxW,  bold: true,
            align: pw.TextAlign.center, size: fsHead),
        col('No. of pieces/packs', pcsW,  bold: true,
            align: pw.TextAlign.center, size: fsHead),
      ]),
      pw.Divider(height: 4, thickness: 0.5),

      // Data rows — tighter vertical padding
      for (int i = 0; i < rows.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Row(children: [
            col(rows[i].productName, prodW),
            col(rows[i].boxes > 0 ? '${rows[i].boxes}' : '',
                boxW, align: pw.TextAlign.center),
            col(rows[i].remainingPieces > 0
                    ? '${rows[i].remainingPieces}'
                    : '',
                pcsW, align: pw.TextAlign.center),
          ]),
        ),
        if (i < rows.length - 1)
          pw.Divider(height: 1, thickness: 0.2),
      ],

      pw.Divider(height: 8, thickness: 0.5),

      // Grand total
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Grand Total: Php ${numFmt.format(grandTotal)}',
          style: ts(bold: true, size: fsHead),
        ),
      ),
    ],
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.layout);
}

// ── Inventory Report PDF ──────────────────────────────────────────────────────

class InventoryReportRow {
  final String productName;
  final int piecesPerBox;
  final int beginning;
  final int stockIn;
  final int stockOutInvoices;
  final int stockOutBO;
  final int stockOutBulkClear;
  final int ending;

  const InventoryReportRow({
    required this.productName,
    required this.piecesPerBox,
    required this.beginning,
    required this.stockIn,
    required this.stockOutInvoices,
    required this.stockOutBO,
    required this.stockOutBulkClear,
    required this.ending,
  });

  int get begBoxes => beginning ~/ piecesPerBox;
  int get begPcs   => beginning % piecesPerBox;
  int get inBoxes  => stockIn ~/ piecesPerBox;
  int get inPcs    => stockIn % piecesPerBox;
  int get outInvBoxes => stockOutInvoices ~/ piecesPerBox;
  int get outInvPcs   => stockOutInvoices % piecesPerBox;
  int get outBOBoxes  => stockOutBO ~/ piecesPerBox;
  int get outBOPcs    => stockOutBO % piecesPerBox;
  int get outBCBoxes  => stockOutBulkClear ~/ piecesPerBox;
  int get outBCPcs    => stockOutBulkClear % piecesPerBox;
  int get endBoxes => ending ~/ piecesPerBox;
  int get endPcs   => ending % piecesPerBox;
}

Future<void> printInventoryReport({
  required DateTime date,
  String? supplierName,
  required List<InventoryReportRow> rows,
  required double totalEndingValue,
  String endingValueLabel = 'Ending Inventory Capital Value',
  required double totalStockInValue,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');

  final pageFormat = PdfPageFormat.a4.copyWith(
    marginTop: 40,
    marginBottom: 40,
    marginLeft: 40,
    marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final prodW = usableW * 0.28;
  final numW  = (usableW - prodW) / 12;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs     = 8.5;
  const double fsHead = 11;

  pw.TextStyle ts({bool bold = false, double? size}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: size ?? fs);

  pw.Widget col(String text, double width,
          {bool bold = false,
           pw.TextAlign align = pw.TextAlign.left,
           double? size}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(text, style: ts(bold: bold, size: size), textAlign: align),
      );

  pw.Widget groupHeader(String text, double width) => pw.Container(
        width: width,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
        ),
        child: pw.Text(text, style: ts(bold: true, size: fsHead - 1)),
      );

  String fmt(int v) => v > 0 ? '$v' : '';

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      pw.Text('Inventory Report', style: ts(bold: true, size: fsHead + 2)),
      pw.SizedBox(height: 4),
      pw.Text('Date: ${dateFmt.format(date)}', style: ts(size: fsHead)),
      if (supplierName != null)
        pw.Text('Supplier: $supplierName', style: ts(size: fsHead)),
      pw.SizedBox(height: 10),

      // Group header row
      pw.Row(children: [
        pw.SizedBox(width: prodW),
        groupHeader('Beginning', numW * 2),
        groupHeader('Stock In',  numW * 2),
        groupHeader('Stock Out', numW * 6),
        groupHeader('Ending',    numW * 2),
      ]),
      // Stock-out sub-group header row
      pw.Row(children: [
        pw.SizedBox(width: prodW),
        pw.SizedBox(width: numW * 2),
        pw.SizedBox(width: numW * 2),
        groupHeader('Invoices',   numW * 2),
        groupHeader('BO',         numW * 2),
        groupHeader('Bulk Clear', numW * 2),
        pw.SizedBox(width: numW * 2),
      ]),
      // Column header row
      pw.Row(children: [
        col('Product', prodW, bold: true, size: fsHead - 1),
        col('Boxes', numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Pcs',   numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Boxes', numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Pcs',   numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Boxes', numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Pcs',   numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Boxes', numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Pcs',   numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Boxes', numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Pcs',   numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Boxes', numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('Pcs',   numW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
      ]),
      pw.Divider(height: 4, thickness: 0.5),

      // Data rows
      for (int i = 0; i < rows.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Row(children: [
            col(rows[i].productName, prodW),
            col(fmt(rows[i].begBoxes), numW, align: pw.TextAlign.center),
            col(fmt(rows[i].begPcs),   numW, align: pw.TextAlign.center),
            col(fmt(rows[i].inBoxes),  numW, align: pw.TextAlign.center),
            col(fmt(rows[i].inPcs),    numW, align: pw.TextAlign.center),
            col(fmt(rows[i].outInvBoxes), numW, align: pw.TextAlign.center),
            col(fmt(rows[i].outInvPcs),   numW, align: pw.TextAlign.center),
            col(fmt(rows[i].outBOBoxes),  numW, align: pw.TextAlign.center),
            col(fmt(rows[i].outBOPcs),    numW, align: pw.TextAlign.center),
            col(fmt(rows[i].outBCBoxes),  numW, align: pw.TextAlign.center),
            col(fmt(rows[i].outBCPcs),    numW, align: pw.TextAlign.center),
            col(fmt(rows[i].endBoxes), numW, align: pw.TextAlign.center),
            col(fmt(rows[i].endPcs),   numW, align: pw.TextAlign.center),
          ]),
        ),
        if (i < rows.length - 1) pw.Divider(height: 1, thickness: 0.2),
      ],

      pw.Divider(height: 8, thickness: 0.5),
      pw.SizedBox(height: 6),
      if (totalStockInValue > 0)
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Stock-in Value: ${_n(totalStockInValue)}',
            style: ts(bold: true, size: fsHead),
          ),
        ),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '$endingValueLabel: ${_n(totalEndingValue)}',
          style: ts(bold: true, size: fsHead),
        ),
      ),
    ],
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.layout);
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

  final pageFormat = PdfPageFormat.a4.copyWith(
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

  final pageFormat = PdfPageFormat.a4.copyWith(
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

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
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
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.loading);
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

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.loading);
}

// ── Remittance Credit PDF ─────────────────────────────────────────────────────

class RemittanceCreditItem {
  final String invoiceNumber;
  final String clientName;
  final DateTime date;
  final String paymentLabel;
  final double outstanding;

  const RemittanceCreditItem({
    required this.invoiceNumber,
    required this.clientName,
    required this.date,
    required this.paymentLabel,
    required this.outstanding,
  });
}

Future<void> printRemittanceCredit({
  required String periodLabel,
  required List<RemittanceCreditItem> items,
}) async {
  final doc     = pw.Document();
  final numFmt  = NumberFormat('#,##0.00');
  final dateFmt = DateFormat('MMM dd, yyyy');
  final grandTotal = items.fold(0.0, (s, i) => s + i.outstanding);

  final pageFormat = PdfPageFormat.a4.copyWith(
    marginTop: 40, marginBottom: 40,
    marginLeft: 40, marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final invNoW  = usableW * 0.18;
  final clientW = usableW * 0.35;
  final dateW   = usableW * 0.20;
  final typeW   = usableW * 0.12;
  final amtW    = usableW * 0.15;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs = 10.0;

  pw.TextStyle ts({bool bold = false}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: fs);
  String php(double v) => 'Php ${numFmt.format(v)}';

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      pw.Text('Total Credits',
          style: ts(bold: true)),
      pw.Text(periodLabel, style: ts()),
      pw.SizedBox(height: 10),

      // Header row
      pw.Row(children: [
        pw.SizedBox(width: invNoW,
            child: pw.Text('Invoice #', style: ts(bold: true))),
        pw.SizedBox(width: clientW,
            child: pw.Text('Store', style: ts(bold: true))),
        pw.SizedBox(width: dateW,
            child: pw.Text('Date', style: ts(bold: true))),
        pw.SizedBox(width: typeW,
            child: pw.Text('Type', style: ts(bold: true))),
        pw.SizedBox(width: amtW,
            child: pw.Text('Outstanding',
                style: ts(bold: true), textAlign: pw.TextAlign.right)),
      ]),
      pw.Divider(height: 6, thickness: 0.5),

      // Data rows
      for (int i = 0; i < items.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(children: [
            pw.SizedBox(width: invNoW,
                child: pw.Text(items[i].invoiceNumber, style: ts())),
            pw.SizedBox(width: clientW,
                child: pw.Text(items[i].clientName, style: ts())),
            pw.SizedBox(width: dateW,
                child: pw.Text(dateFmt.format(items[i].date), style: ts())),
            pw.SizedBox(width: typeW,
                child: pw.Text(items[i].paymentLabel, style: ts())),
            pw.SizedBox(width: amtW,
                child: pw.Text(php(items[i].outstanding),
                    style: ts(), textAlign: pw.TextAlign.right)),
          ]),
        ),
        if (i < items.length - 1)
          pw.Divider(height: 1, thickness: 0.2),
      ],

      pw.Divider(height: 8, thickness: 0.5),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Total Outstanding: ${php(grandTotal)}',
            style: pw.TextStyle(font: fontBold, fontSize: fs + 2)),
      ),
    ],
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.remittance);
}

// ── Supplier Delivery Receipt ─────────────────────────────────────────────────

Future<void> printSupplierReceivedInvoice({
  required SupplierReceivedInvoice invoice,
  required Supplier supplier,
  required List<SupplierReceivedInvoiceItem> items,
  required Map<String, Product> productsById,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');

  final pageFormat = PdfPageFormat.a4.copyWith(
    marginTop: 40,
    marginBottom: 40,
    marginLeft: 40,
    marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final prodW  = usableW * 0.30;
  final qtyW   = usableW * 0.12;
  final priceW = (usableW - prodW - qtyW) / 4;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs     = 8.5;
  const double fsHead = 11;

  pw.TextStyle ts({bool bold = false, double? size}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: size ?? fs);

  pw.Widget col(String text, double width,
          {bool bold = false,
           pw.TextAlign align = pw.TextAlign.left,
           double? size}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(text, style: ts(bold: bold, size: size), textAlign: align),
      );

  String qtyLabel(SupplierReceivedInvoiceItem item) {
    final product = productsById[item.productId];
    final ppb = product?.piecesPerBox ?? 0;
    if (ppb <= 0) return '${item.quantity} pcs';
    final boxes = item.quantity ~/ ppb;
    final pcs   = item.quantity % ppb;
    return boxes > 0
        ? '$boxes box(es)${pcs > 0 ? ' + $pcs pcs' : ''}'
        : '$pcs pcs';
  }

  double totalSystem = 0;
  double totalSupplier = 0;
  for (final item in items) {
    totalSystem += item.subtotalSystem;
    totalSupplier += item.subtotalSupplier;
  }

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      pw.Text('Supplier Delivery Receipt',
          style: ts(bold: true, size: fsHead + 2)),
      pw.SizedBox(height: 4),
      pw.Text('Date: ${dateFmt.format(invoice.receivedDate)}',
          style: ts(size: fsHead)),
      pw.Text('Supplier: ${supplier.name}', style: ts(size: fsHead)),
      if (invoice.referenceNumber != null && invoice.referenceNumber!.isNotEmpty)
        pw.Text('Reference #: ${invoice.referenceNumber}',
            style: ts(size: fsHead)),
      pw.SizedBox(height: 10),

      // Column header row
      pw.Row(children: [
        col('Product', prodW, bold: true, size: fsHead - 1),
        col('Qty', qtyW, bold: true, align: pw.TextAlign.center, size: fsHead - 1),
        col('System Price', priceW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
        col('Supplier Price', priceW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
        col('Subtotal (System)', priceW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
        col('Subtotal (Supplier)', priceW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
      ]),
      pw.Divider(height: 4, thickness: 0.5),

      // Data rows
      for (int i = 0; i < items.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Row(children: [
            col(
                (productsById[items[i].productId]?.name ?? items[i].productId) +
                    (items[i].isFree ? ' (FREE)' : ''),
                prodW),
            col(qtyLabel(items[i]), qtyW, align: pw.TextAlign.center),
            col(_n(items[i].systemPrice), priceW, align: pw.TextAlign.right),
            col(_n(items[i].supplierPrice), priceW, align: pw.TextAlign.right),
            col(_n(items[i].subtotalSystem), priceW, align: pw.TextAlign.right),
            col(_n(items[i].subtotalSupplier), priceW, align: pw.TextAlign.right),
          ]),
        ),
        if (i < items.length - 1) pw.Divider(height: 1, thickness: 0.2),
      ],

      pw.Divider(height: 8, thickness: 0.5),
      pw.SizedBox(height: 6),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('System Total: ${_n(totalSystem)}',
            style: ts(bold: true, size: fsHead)),
      ),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Supplier Total: ${_n(totalSupplier)}',
            style: ts(bold: true, size: fsHead)),
      ),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Difference: ${_n(totalSupplier - totalSystem)}',
            style: ts(bold: true, size: fsHead)),
      ),
    ],
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.supplierDelivery);
}

Future<void> printPurchaseOrder({
  required PurchaseOrder order,
  required Supplier supplier,
  required List<PurchaseOrderItem> items,
  required Map<String, Product> productsById,
}) async {
  final doc     = pw.Document();
  final dateFmt = DateFormat('MMMM dd, yyyy');

  final pageFormat = PdfPageFormat.a4.copyWith(
    marginTop: 40,
    marginBottom: 40,
    marginLeft: 40,
    marginRight: 40,
  );
  final usableW = pageFormat.availableWidth;
  final prodW  = usableW * 0.40;
  final pkgW   = usableW * 0.20;
  final colW   = (usableW - prodW - pkgW) / 3;

  final font     = pw.Font.helvetica();
  final fontBold = pw.Font.helveticaBold();
  const double fs     = 8.5;
  const double fsHead = 11;

  pw.TextStyle ts({bool bold = false, double? size}) =>
      pw.TextStyle(font: bold ? fontBold : font, fontSize: size ?? fs);

  pw.Widget col(String text, double width,
          {bool bold = false,
           pw.TextAlign align = pw.TextAlign.left,
           double? size}) =>
      pw.SizedBox(
        width: width,
        child: pw.Text(text, style: ts(bold: bold, size: size), textAlign: align),
      );

  final grandTotal = items.fold(0.0, (s, i) => s + i.amount);

  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat,
    build: (ctx) => [
      pw.Text('Purchase Order', style: ts(bold: true, size: fsHead + 2)),
      pw.SizedBox(height: 4),
      pw.Text('Date: ${dateFmt.format(order.orderDate)}', style: ts(size: fsHead)),
      pw.Text('Supplier: ${supplier.name}', style: ts(size: fsHead)),
      if (order.referenceNumber != null && order.referenceNumber!.isNotEmpty)
        pw.Text('Reference #: ${order.referenceNumber}', style: ts(size: fsHead)),
      pw.SizedBox(height: 10),

      // Column header row
      pw.Row(children: [
        col('Product Description', prodW, bold: true, size: fsHead - 1),
        col('Packaging', pkgW, bold: true, size: fsHead - 1),
        col('Price', colW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
        col('# of Case', colW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
        col('Amount', colW, bold: true, align: pw.TextAlign.right, size: fsHead - 1),
      ]),
      pw.Divider(height: 4, thickness: 0.5),

      // Data rows
      for (int i = 0; i < items.length; i++) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
          child: pw.Row(children: [
            col(productsById[items[i].productId]?.name ?? items[i].productId, prodW),
            col(
              productsById[items[i].productId] != null
                  ? packagingLabel(productsById[items[i].productId]!)
                  : '',
              pkgW,
            ),
            col(_n(items[i].price), colW, align: pw.TextAlign.right),
            col(_n(items[i].cases), colW, align: pw.TextAlign.right),
            col(_n(items[i].amount), colW, align: pw.TextAlign.right),
          ]),
        ),
        if (i < items.length - 1) pw.Divider(height: 1, thickness: 0.2),
      ],

      pw.Divider(height: 8, thickness: 0.5),
      pw.SizedBox(height: 6),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Grand Total: ${_n(grandTotal)}',
            style: ts(bold: true, size: fsHead)),
      ),
    ],
  ));

  await _printWithSlot(
    doc: doc, format: pageFormat, slot: PrinterSettingsService.purchaseOrder);
}

