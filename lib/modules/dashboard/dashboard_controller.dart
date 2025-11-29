import 'package:get/get.dart';
import '../../data/repositories/transaction_repo.dart';
import '../../core/utils/date.dart' as date_utils;

class DashboardController extends GetxController {
  final TransactionRepository _transactionRepo;

  DashboardController(this._transactionRepo);

  // State
  final dailySales = 0.0.obs;
  final outstandingReceivables = 0.0.obs;
  final cashInDrawer = 0.0.obs;
  final transactionCount = 0.obs;
  final isLoading = false.obs;

  // Date range for stats
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadTodayStats();
  }

  /// Load stats for today
  void loadTodayStats() {
    final now = DateTime.now();
    final start = date_utils.DateUtils.startOfDay(now);
    final end = date_utils.DateUtils.endOfDay(now);
    loadStats(start, end);
  }

  /// Load stats for this week
  void loadWeekStats() {
    final now = DateTime.now();
    final start = date_utils.DateUtils.startOfWeek(now);
    final end = date_utils.DateUtils.endOfWeek(now);
    loadStats(start, end);
  }

  /// Load stats for this month
  void loadMonthStats() {
    final now = DateTime.now();
    final start = date_utils.DateUtils.startOfMonth(now);
    final end = date_utils.DateUtils.endOfMonth(now);
    loadStats(start, end);
  }

  /// Load stats for custom date range
  void loadStats(DateTime start, DateTime end) {
    isLoading.value = true;
    startDate.value = start;
    endDate.value = end;

    try {
      // Calculate stats
      dailySales.value = _transactionRepo.getTotalSales(start, end);
      outstandingReceivables.value = _transactionRepo.getOutstandingReceivables();
      cashInDrawer.value = _transactionRepo.getCashInDrawer();
      transactionCount.value = _transactionRepo.getTransactionCount(start, end);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh current stats
  void refresh() {
    loadStats(startDate.value, endDate.value);
  }
}
