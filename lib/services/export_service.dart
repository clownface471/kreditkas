import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/models/transaction.dart';
import '../data/models/payment.dart';
import '../core/utils/currency.dart';
import '../core/utils/date.dart' as date_utils;

class ExportService {
  /// Export transactions to CSV
  String exportTransactionsToCsv(List<Transaction> transactions) {
    final rows = <List<String>>[];

    // Header
    rows.add([
      'ID',
      'Date',
      'Customer ID',
      'Items Count',
      'Subtotal',
      'Discount',
      'Tax',
      'Total',
      'Method',
      'Paid',
      'Change',
      'Remaining Balance',
    ]);

    // Data rows
    for (final tx in transactions) {
      rows.add([
        tx.id,
        date_utils.DateUtils.formatDateTime(tx.date),
        tx.customerId ?? '',
        tx.items.length.toString(),
        tx.subtotal.toStringAsFixed(2),
        tx.discount.toStringAsFixed(2),
        tx.tax.toStringAsFixed(2),
        tx.total.toStringAsFixed(2),
        tx.method.name,
        tx.paid.toStringAsFixed(2),
        tx.change.toStringAsFixed(2),
        tx.remainingBalance.toStringAsFixed(2),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export transactions to PDF
  Future<Uint8List> exportTransactionsToPdf(List<Transaction> transactions) async {
    final pdf = pw.Document();

    // Split transactions into pages (max 20 per page)
    final pageSize = 20;
    for (var i = 0; i < transactions.length; i += pageSize) {
      final pageTransactions = transactions.skip(i).take(pageSize).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Transactions Report',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Page ${(i ~/ pageSize) + 1} of ${((transactions.length - 1) ~/ pageSize) + 1}'),
                pw.SizedBox(height: 16),
                _buildTransactionsTable(pageTransactions),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildTransactionsTable(List<Transaction> transactions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(80),
        1: const pw.FixedColumnWidth(100),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(60),
        4: const pw.FixedColumnWidth(80),
        5: const pw.FixedColumnWidth(60),
        6: const pw.FixedColumnWidth(80),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildCell('ID', isHeader: true),
            _buildCell('Date', isHeader: true),
            _buildCell('Customer', isHeader: true),
            _buildCell('Items', isHeader: true),
            _buildCell('Total', isHeader: true),
            _buildCell('Method', isHeader: true),
            _buildCell('Balance', isHeader: true),
          ],
        ),
        // Data rows
        ...transactions.map((tx) {
          return pw.TableRow(
            children: [
              _buildCell(tx.id.substring(0, 8)),
              _buildCell(date_utils.DateUtils.formatDisplayDate(tx.date)),
              _buildCell(tx.customerId?.substring(0, 8) ?? 'N/A'),
              _buildCell(tx.items.length.toString()),
              _buildCell(CurrencyUtils.format(tx.total)),
              _buildCell(tx.method.name.toUpperCase()),
              _buildCell(CurrencyUtils.format(tx.remainingBalance)),
            ],
          );
        }),
      ],
    );
  }

  /// Export receivables to CSV
  String exportReceivablesToCsv(List<Transaction> creditTransactions) {
    final rows = <List<String>>[];

    // Header
    rows.add([
      'Transaction ID',
      'Date',
      'Customer ID',
      'Total Amount',
      'Paid',
      'Remaining Balance',
      'Days Outstanding',
    ]);

    // Data rows
    final now = DateTime.now();
    for (final tx in creditTransactions) {
      if (tx.remainingBalance <= 0) continue;

      final daysOutstanding = now.difference(tx.date).inDays;
      rows.add([
        tx.id,
        date_utils.DateUtils.formatDate(tx.date),
        tx.customerId ?? '',
        tx.total.toStringAsFixed(2),
        tx.paid.toStringAsFixed(2),
        tx.remainingBalance.toStringAsFixed(2),
        daysOutstanding.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export cash report to CSV
  String exportCashReportToCsv(List<Transaction> cashTransactions) {
    final rows = <List<String>>[];

    // Header
    rows.add([
      'Transaction ID',
      'Date',
      'Total',
      'Paid',
      'Change',
    ]);

    // Data rows
    for (final tx in cashTransactions.where((t) => t.method == PaymentMethod.cash)) {
      rows.add([
        tx.id,
        date_utils.DateUtils.formatDateTime(tx.date),
        tx.total.toStringAsFixed(2),
        tx.paid.toStringAsFixed(2),
        tx.change.toStringAsFixed(2),
      ]);
    }

    // Summary
    final totalCash = cashTransactions
        .where((t) => t.method == PaymentMethod.cash)
        .fold(0.0, (sum, t) => sum + t.paid);

    rows.add(['', '', '', 'Total:', totalCash.toStringAsFixed(2)]);

    return const ListToCsvConverter().convert(rows);
  }

  /// Export payments to CSV
  String exportPaymentsToCsv(List<Payment> payments) {
    final rows = <List<String>>[];

    // Header
    rows.add([
      'Payment ID',
      'Transaction ID',
      'Date',
      'Amount',
      'Method',
      'Note',
    ]);

    // Data rows
    for (final payment in payments) {
      rows.add([
        payment.id,
        payment.transactionId,
        date_utils.DateUtils.formatDateTime(payment.date),
        payment.amount.toStringAsFixed(2),
        payment.method.name,
        payment.note ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  pw.Widget _buildCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
