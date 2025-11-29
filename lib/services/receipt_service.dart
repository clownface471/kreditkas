import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/models/transaction.dart';
import '../data/models/store_profile.dart';
import '../data/models/payment.dart';
import '../core/utils/currency.dart';
import '../core/utils/date.dart' as date_utils;

class ReceiptService {
  /// Build a PDF receipt from transaction and store profile
  Future<Uint8List> buildReceipt(
    Transaction transaction,
    StoreProfile profile, {
    String? customerName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(profile),
              pw.SizedBox(height: 24),

              // Transaction meta
              _buildTransactionMeta(transaction, customerName),
              pw.SizedBox(height: 16),

              // Items table
              _buildItemsTable(transaction),
              pw.SizedBox(height: 16),

              // Summary
              _buildSummary(transaction),
              pw.SizedBox(height: 16),

              // Payment info
              _buildPaymentInfo(transaction),

              // Credit details
              if (transaction.method == PaymentMethod.credit && transaction.creditPlan != null)
                ...[
                  pw.SizedBox(height: 16),
                  _buildCreditDetails(transaction),
                ],

              pw.Spacer(),

              // Footer
              _buildFooter(profile),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(StoreProfile profile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          profile.name,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (profile.address != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(profile.address!),
        ],
        if (profile.phone != null || profile.email != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            [profile.phone, profile.email].where((e) => e != null).join(' • '),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildTransactionMeta(Transaction transaction, String? customerName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Transaction ID: ${transaction.id}'),
            pw.Text(date_utils.DateUtils.formatDisplayDateTime(transaction.date)),
          ],
        ),
        if (customerName != null) ...[
          pw.SizedBox(height: 4),
          pw.Text('Customer: $customerName'),
        ],
      ],
    );
  }

  pw.Widget _buildItemsTable(Transaction transaction) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Item', isHeader: true),
            _buildTableCell('Unit Price', isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('Total', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        // Items
        ...transaction.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.qty.toString()),
              _buildTableCell(item.name),
              _buildTableCell(CurrencyUtils.format(item.unitPrice), align: pw.TextAlign.right),
              _buildTableCell(CurrencyUtils.format(item.lineTotal), align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildSummary(Transaction transaction) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _buildSummaryRow('Subtotal:', CurrencyUtils.format(transaction.subtotal)),
            if (transaction.discount > 0)
              _buildSummaryRow('Discount:', '- ${CurrencyUtils.format(transaction.discount)}'),
            if (transaction.tax > 0)
              _buildSummaryRow('Tax:', CurrencyUtils.format(transaction.tax)),
            pw.Divider(),
            _buildSummaryRow(
              'Total:',
              CurrencyUtils.format(transaction.total),
              isBold: true,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentInfo(Transaction transaction) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Payment Method: ${transaction.method.name.toUpperCase()}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        if (transaction.method == PaymentMethod.cash) ...[
          pw.SizedBox(height: 4),
          pw.Text('Paid: ${CurrencyUtils.format(transaction.paid)}'),
          pw.Text('Change: ${CurrencyUtils.format(transaction.change)}'),
        ],
      ],
    );
  }

  pw.Widget _buildCreditDetails(Transaction transaction) {
    final plan = transaction.creditPlan!;
    final principal = transaction.total;
    final monthly = plan.monthly(principal);
    final totalInterest = plan.totalInterest(principal);
    final nextDueDate = date_utils.DateUtils.addMonths(transaction.date, 1);

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Credit Plan Details',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Tenor: ${plan.tenorMonths} months'),
          pw.Text('Interest Rate: ${plan.interestRate}% per month'),
          if (plan.downPayment > 0)
            pw.Text('Down Payment: ${CurrencyUtils.format(plan.downPayment)}'),
          pw.Text('Monthly Payment: ${CurrencyUtils.format(monthly)}'),
          pw.Text('Total Interest: ${CurrencyUtils.format(totalInterest)}'),
          pw.Text('Next Due Date: ${date_utils.DateUtils.formatDisplayDate(nextDueDate)}'),
          pw.SizedBox(height: 4),
          pw.Text(
            'Remaining Balance: ${CurrencyUtils.format(transaction.remainingBalance)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(StoreProfile profile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        if (profile.footerNote != null)
          pw.Text(
            profile.footerNote!,
            textAlign: pw.TextAlign.center,
          ),
        if (profile.returnPolicy != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            profile.returnPolicy!,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ],
    );
  }
}
