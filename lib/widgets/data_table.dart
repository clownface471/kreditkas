import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomDataTable<T> extends StatelessWidget {
  final List<DataTableColumn> columns;
  final List<T> items;
  final List<Widget> Function(T item) buildRow;
  final VoidCallback? onRefresh;
  final bool isLoading;
  final String? emptyMessage;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.items,
    required this.buildRow,
    this.onRefresh,
    this.isLoading = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No data available',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: columns
              .map((col) => DataColumn(
                    label: Text(col.label),
                    numeric: col.numeric,
                    tooltip: col.tooltip,
                  ))
              .toList(),
          rows: items.map((item) {
            return DataRow(cells: buildRow(item).map((widget) {
              return DataCell(widget);
            }).toList());
          }).toList(),
          headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.tableRowHover;
            }
            return null;
          }),
        ),
      ),
    );
  }
}

class DataTableColumn {
  final String label;
  final bool numeric;
  final String? tooltip;

  const DataTableColumn({
    required this.label,
    this.numeric = false,
    this.tooltip,
  });
}
