import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';

/// Pie chart widget for category-wise expense visualization
class CategoryPieChart extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryPieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();
    
    if (categoryData.isEmpty) {
      return const Center(
        child: Text('No expenses to display'),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: categoryData.map((data) => _buildPieSection(data)).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<CategoryData> _getCategoryData() {
    final Map<String, double> categoryTotals = {};
    
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals.entries
        .map((entry) => CategoryData(entry.key, entry.value))
        .toList();
  }

  PieChartSectionData _buildPieSection(CategoryData data) {
    final colors = {
      'Food': Colors.orange,
      'Travel': Colors.blue,
      'Shopping': Colors.purple,
      'Bills': Colors.red,
      'Other': Colors.grey,
    };

    return PieChartSectionData(
      value: data.amount,
      title: '${data.category}\n${CurrencyFormatter.formatCompact(data.amount)}',
      color: colors[data.category] ?? Colors.grey,
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class CategoryData {
  final String category;
  final double amount;

  CategoryData(this.category, this.amount);
}