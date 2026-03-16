import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No category data yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add expenses to see breakdown',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: categoryData.map((data) => _buildPieSection(data)).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events if needed
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(categoryData),
      ],
    );
  }

  Widget _buildLegend(List<CategoryData> categoryData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryData.map((data) {
        final color = _getCategoryColor(data.category);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${data.category} (${CurrencyFormatter.formatCompact(data.amount)})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
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
        .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount)); // Sort by amount descending
  }

  PieChartSectionData _buildPieSection(CategoryData data) {
    final color = _getCategoryColor(data.category);
    final total = _getCategoryData().fold<double>(0, (sum, item) => sum + item.amount);
    final percentage = (data.amount / total * 100).round();

    return PieChartSectionData(
      value: data.amount,
      title: '$percentage%',
      color: color,
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: null,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFF97316); // Orange
      case 'Travel':
        return const Color(0xFF3B82F6); // Blue
      case 'Shopping':
        return const Color(0xFF8B5CF6); // Purple
      case 'Bills':
        return const Color(0xFFEF4444); // Red
      case 'Other':
        return const Color(0xFF6B7280); // Gray
      default:
        return AppTheme.primaryColor;
    }
  }
}

class CategoryData {
  final String category;
  final double amount;

  CategoryData(this.category, this.amount);
}