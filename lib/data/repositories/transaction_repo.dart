import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../models/payment.dart';
import '../storage/db_service.dart';

class TransactionRepository {
  final DbService _db = DbService.instance;

  Box<Transaction> get _box => _db.transactions;
  Box<Payment> get _paymentsBox => _db.payments;

  /// Get all transactions
  List<Transaction> getAll() {
    return _box.values.toList();
  }

  /// Get transaction by ID
  Transaction? getById(String id) {
    return _box.get(id);
  }

  /// Get transactions by date range
  List<Transaction> getByDateRange(DateTime start, DateTime end) {
    return _box.values.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get transactions by customer
  List<Transaction> getByCustomer(String customerId) {
    return _box.values.where((t) => t.customerId == customerId).toList();
  }

  /// Get transactions by payment method
  List<Transaction> getByMethod(PaymentMethod method) {
    return _box.values.where((t) => t.method == method).toList();
  }

  /// Get credit transactions (with remaining balance)
  List<Transaction> getCreditTransactions() {
    return _box.values
        .where((t) => t.method == PaymentMethod.credit && t.remainingBalance > 0)
        .toList();
  }

  /// Get transactions for today
  List<Transaction> getToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getByDateRange(start, end);
  }

  /// Add a new transaction
  Future<void> add(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  /// Update an existing transaction
  Future<void> update(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  /// Delete a transaction (void)
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Record a payment against a credit transaction
  Future<bool> recordPayment(Payment payment) async {
    final transaction = getById(payment.transactionId);
    if (transaction == null) return false;

    if (transaction.method != PaymentMethod.credit) return false;

    // Update remaining balance
    final newBalance = transaction.remainingBalance - payment.amount;
    final updated = transaction.copyWith(
      remainingBalance: newBalance < 0 ? 0 : newBalance,
    );
    await update(updated);

    // Store the payment
    await _paymentsBox.put(payment.id, payment);

    return true;
  }

  /// Get payments for a transaction
  List<Payment> getPayments(String transactionId) {
    return _paymentsBox.values
        .where((p) => p.transactionId == transactionId)
        .toList();
  }

  /// Get all payments
  List<Payment> getAllPayments() {
    return _paymentsBox.values.toList();
  }

  /// Calculate total sales for a date range
  double getTotalSales(DateTime start, DateTime end) {
    return getByDateRange(start, end)
        .fold(0.0, (sum, t) => sum + t.total);
  }

  /// Calculate outstanding receivables
  double getOutstandingReceivables() {
    return getCreditTransactions()
        .fold(0.0, (sum, t) => sum + t.remainingBalance);
  }

  /// Calculate cash in drawer (total cash payments)
  double getCashInDrawer() {
    return getByMethod(PaymentMethod.cash)
        .fold(0.0, (sum, t) => sum + t.paid);
  }

  /// Get transaction count for a date range
  int getTransactionCount(DateTime start, DateTime end) {
    return getByDateRange(start, end).length;
  }

  /// Get receivables grouped by customer
  Map<String, double> getReceivablesByCustomer() {
    final receivables = <String, double>{};
    for (final transaction in getCreditTransactions()) {
      final customerId = transaction.customerId ?? 'unknown';
      receivables[customerId] = (receivables[customerId] ?? 0) + transaction.remainingBalance;
    }
    return receivables;
  }

  /// Get aging buckets for receivables
  Map<String, List<Transaction>> getAgingBuckets() {
    final now = DateTime.now();
    final current = <Transaction>[];
    final days30 = <Transaction>[];
    final days60 = <Transaction>[];
    final days90Plus = <Transaction>[];

    for (final transaction in getCreditTransactions()) {
      final daysPast = now.difference(transaction.date).inDays;
      if (daysPast <= 30) {
        current.add(transaction);
      } else if (daysPast <= 60) {
        days30.add(transaction);
      } else if (daysPast <= 90) {
        days60.add(transaction);
      } else {
        days90Plus.add(transaction);
      }
    }

    return {
      'current': current,
      '30-60': days30,
      '60-90': days60,
      '90+': days90Plus,
    };
  }
}
