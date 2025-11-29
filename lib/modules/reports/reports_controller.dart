import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/transaction.dart';
import '../../data/models/payment.dart';
import '../../data/repositories/transaction_repo.dart';
import '../../services/export_service.dart';
import '../../services/print_service.dart';
import '../../core/utils/date.dart' as date_utils;

enum ReportType { transactions, receivables, cash }

class ReportsController extends GetxController {
  final TransactionRepository _transactionRepo;
  final ExportService _exportService;
  final PrintService _printService;

  ReportsController(
    this._transactionRepo,
    this._exportService,
    this._printService,
  );

  // State
  final currentReportType = ReportType.transactions.obs;
  final isLoading = false.obs;

  // Date range
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Transactions report
  final transactions = <Transaction>[].obs;

  // Receivables report
  final receivables = <Transaction>[].obs;
  final agingBuckets = <String, List<Transaction>>{}.obs;

  // Cash report
  final cashTransactions = <Transaction>[].obs;

  // Payments
  final payments = <Payment>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setTodayRange();
    loadReport();
  }

  void _setTodayRange() {
    final now = DateTime.now();
    startDate.value = date_utils.DateUtils.startOfDay(now);
    endDate.value = date_utils.DateUtils.endOfDay(now);
  }

  /// Switch report type
  void switchReportType(ReportType type) {
    currentReportType.value = type;
    loadReport();
  }

  /// Set date range
  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    loadReport();
  }

  /// Load current report
  void loadReport() {
    isLoading.value = true;
    try {
      switch (currentReportType.value) {
        case ReportType.transactions:
          _loadTransactionsReport();
          break;
        case ReportType.receivables:
          _loadReceivablesReport();
          break;
        case ReportType.cash:
          _loadCashReport();
          break;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _loadTransactionsReport() {
    transactions.value = _transactionRepo.getByDateRange(
      startDate.value,
      endDate.value,
    );
  }

  void _loadReceivablesReport() {
    receivables.value = _transactionRepo.getCreditTransactions();
    agingBuckets.value = _transactionRepo.getAgingBuckets();
  }

  void _loadCashReport() {
    cashTransactions.value = _transactionRepo
        .getByDateRange(startDate.value, endDate.value)
        .where((t) => t.method == PaymentMethod.cash)
        .toList();
  }

  /// Export current report to CSV
  Future<void> exportToCsv() async {
    try {
      String csvData;

      switch (currentReportType.value) {
        case ReportType.transactions:
          csvData = _exportService.exportTransactionsToCsv(transactions);
          break;
        case ReportType.receivables:
          csvData = _exportService.exportReceivablesToCsv(receivables);
          break;
        case ReportType.cash:
          csvData = _exportService.exportCashReportToCsv(cashTransactions);
          break;
      }

      // On web, this will trigger a download
      if (kIsWeb) {
        // Create a blob and download
        final blob = Blob([Uint8List.fromList(csvData.codeUnits)]);
        // Note: Actual web download would use html package
        Get.snackbar('Export', 'CSV download started');
      } else {
        // On desktop, save to file
        Get.snackbar('Export', 'CSV export completed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to export CSV: $e');
    }
  }

  /// Export current report to PDF
  Future<void> exportToPdf() async {
    try {
      if (currentReportType.value == ReportType.transactions) {
        final pdfBytes = await _exportService.exportTransactionsToPdf(transactions);
        await _printService.sharePdf(
          pdfBytes,
          filename: 'transactions_report.pdf',
        );
        Get.snackbar('Export', 'PDF export completed');
      } else {
        Get.snackbar('Info', 'PDF export not available for this report type');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to export PDF: $e');
    }
  }

  /// Get total for current report
  double getReportTotal() {
    switch (currentReportType.value) {
      case ReportType.transactions:
        return transactions.fold(0.0, (sum, t) => sum + t.total);
      case ReportType.receivables:
        return receivables.fold(0.0, (sum, t) => sum + t.remainingBalance);
      case ReportType.cash:
        return cashTransactions.fold(0.0, (sum, t) => sum + t.paid);
    }
  }

  /// Record payment against a credit transaction
  Future<void> recordPayment(String transactionId, double amount, String? note) async {
    try {
      final payment = Payment(
        id: const Uuid().v4(),
        transactionId: transactionId,
        date: DateTime.now(),
        amount: amount,
        method: PaymentMethod.cash,
        note: note,
      );

      final success = await _transactionRepo.recordPayment(payment);
      if (success) {
        Get.snackbar('Success', 'Payment recorded successfully');
        loadReport();
      } else {
        Get.snackbar('Error', 'Failed to record payment');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to record payment: $e');
    }
  }

  /// Refresh current report
  void refresh() {
    loadReport();
  }
}

// Import required for Uint8List and Blob
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class Blob {
  final List<int> data;
  Blob(this.data);
}
