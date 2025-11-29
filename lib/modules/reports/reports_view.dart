import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/app_bar.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date.dart' as date_utils;
import 'reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarNav(),
          Expanded(
            child: Column(
              children: [
                CustomAppBar(
                  title: 'Reports',
                  actions: [
                    AppBarAction(
                      icon: Icons.file_download,
                      tooltip: 'Export CSV',
                      onPressed: controller.exportToCsv,
                    ),
                    AppBarAction(
                      icon: Icons.picture_as_pdf,
                      tooltip: 'Export PDF',
                      onPressed: controller.exportToPdf,
                    ),
                    AppBarAction(
                      icon: Icons.refresh,
                      tooltip: 'Refresh',
                      onPressed: controller.refresh,
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Report type tabs
                      Obx(() => SegmentedButton<ReportType>(
                            segments: const [
                              ButtonSegment(
                                value: ReportType.transactions,
                                label: Text('Transactions'),
                              ),
                              ButtonSegment(
                                value: ReportType.receivables,
                                label: Text('Receivables'),
                              ),
                              ButtonSegment(
                                value: ReportType.cash,
                                label: Text('Cash'),
                              ),
                            ],
                            selected: {controller.currentReportType.value},
                            onSelectionChanged: (Set<ReportType> selected) {
                              controller.switchReportType(selected.first);
                            },
                          )),

                      const SizedBox(height: 16),

                      // Report content
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return _buildReportContent();
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return Obx(() {
      switch (controller.currentReportType.value) {
        case ReportType.transactions:
          return _buildTransactionsReport();
        case ReportType.receivables:
          return _buildReceivablesReport();
        case ReportType.cash:
          return _buildCashReport();
      }
    });
  }

  Widget _buildTransactionsReport() {
    return Obx(() {
      final transactions = controller.transactions;

      if (transactions.isEmpty) {
        return const Center(child: Text('No transactions found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Card(
            child: ListTile(
              title: Text('Transaction #${tx.id.substring(0, 8)}'),
              subtitle: Text(date_utils.DateUtils.formatDisplayDateTime(tx.date)),
              trailing: Text(
                CurrencyUtils.format(tx.total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildReceivablesReport() {
    return Obx(() {
      final receivables = controller.receivables;

      if (receivables.isEmpty) {
        return const Center(child: Text('No receivables found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: receivables.length,
        itemBuilder: (context, index) {
          final tx = receivables[index];
          return Card(
            child: ListTile(
              title: Text('Transaction #${tx.id.substring(0, 8)}'),
              subtitle: Text('Customer: ${tx.customerId ?? "Unknown"}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.format(tx.remainingBalance),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'of ${CurrencyUtils.format(tx.total)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCashReport() {
    return Obx(() {
      final cashTxs = controller.cashTransactions;

      if (cashTxs.isEmpty) {
        return const Center(child: Text('No cash transactions found'));
      }

      final total = cashTxs.fold(0.0, (sum, tx) => sum + tx.paid);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Cash:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyUtils.format(total),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cashTxs.length,
              itemBuilder: (context, index) {
                final tx = cashTxs[index];
                return Card(
                  child: ListTile(
                    title: Text('Transaction #${tx.id.substring(0, 8)}'),
                    subtitle: Text(date_utils.DateUtils.formatDisplayDateTime(tx.date)),
                    trailing: Text(
                      CurrencyUtils.format(tx.paid),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
