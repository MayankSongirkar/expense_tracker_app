import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense.dart';

/// Bar chart widget for monthly expense visualization
class MonthlyBarChart extends StatelessWidget {
  final List<Expense> expenses;

  const MonthlyBarChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();
    
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    DateHelper.getMonthName(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlyData.entries
              .map((entry) => _buildBarGroup(entry.key, entry.value))
              .toList(),
        ),
      ),
    );
  }

  Map<int, double> _getMonthlyData() {
    final Map<int, double> monthlyTotals = {};
    
    for (final expense in expenses) {
      final month = expense.date.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + expense.amount;
    }

    return monthlyTotals;
  }

  BarChartGroupData _buildBarGroup(int month, double amount) {
    return BarChartGroupData(
      x: month,
      barRods: [
        BarChartRodData(
          toY: amount,
          color: Colors.blue,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}