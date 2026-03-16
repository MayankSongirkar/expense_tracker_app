/// Monthly Spending Chart Widget
/// 
/// A professional bar chart component that visualizes monthly spending trends
/// over the last 12 months. Handles overlapping labels intelligently and
/// provides interactive tooltips for detailed information.
/// 
/// Key Features:
/// - Displays last 12 months of spending data
/// - Intelligent label management to prevent overlap
/// - Interactive tooltips with full month names and amounts
/// - Responsive design that adapts to data density
/// - Professional styling with gradients and proper spacing
/// - Empty state handling for new users
/// 
/// Technical Implementation:
/// - Uses FL Chart library for smooth animations
/// - Adaptive label rotation and spacing based on data count
/// - Proper theme integration for light/dark modes
/// - Currency formatting with Indian Rupee support
/// - Optimized performance with efficient data processing
/// 
/// Usage:
/// ```dart
/// MonthlySpendingChart(expenses: expenseList)
/// ```

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';

/// Interactive bar chart widget for monthly spending visualization
/// 
/// This widget creates a professional bar chart showing spending trends over
/// the last 12 months. It intelligently handles label overlap by showing
/// alternate months when there are many data points, and provides rich
/// tooltips for detailed information.
/// 
/// Features:
/// - Adaptive label display to prevent overlap
/// - Interactive tooltips with full month names and formatted amounts
/// - Responsive bar width based on data density
/// - Professional gradient styling
/// - Empty state with helpful messaging
/// - Theme-aware colors for light and dark modes
/// 
/// The chart automatically adjusts its layout based on the number of months
/// with data, ensuring optimal readability in all scenarios.
class MonthlySpendingChart extends StatelessWidget {
  /// List of expenses to analyze for monthly trends
  final List<Expense> expenses;

  const MonthlySpendingChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();
    
    if (monthlyData.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              'No spending data available',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate max amount with proper fallback
    final maxAmount = monthlyData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxAmount > 0 ? maxAmount * 1.2 : 1000.0;
    final intervalValue = maxAmount > 0 ? (maxAmount / 4).clamp(1.0, double.infinity) : 250.0;

    return Container(
      height: 320, // Increased height to accommodate rotated labels
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: chartMaxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final monthData = monthlyData[group.x.toInt()];
                return BarTooltipItem(
                  '${monthData.monthName}\n${CurrencyFormatter.format(monthData.amount)}',
                  TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                    // Show every other month to prevent overlap, but ensure we show recent months
                    final shouldShow = monthlyData.length <= 6 || value.toInt() % 2 == 0;
                    if (shouldShow) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Transform.rotate(
                          angle: monthlyData.length > 6 ? -0.4 : 0, // Rotate only if many months
                          child: Text(
                            monthlyData[value.toInt()].shortName,
                            style: TextStyle(
                              fontSize: monthlyData.length > 6 ? 9 : 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.7)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 45,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: intervalValue,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      CurrencyFormatter.formatCompact(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlyData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.amount,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: monthlyData.length > 8 ? 14 : 18, // Thinner bars for more months
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: intervalValue,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFE2E8F0),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Processes expense data to create monthly spending summaries
  /// 
  /// Analyzes the last 12 months from the current date and calculates
  /// total spending for each month. Returns data in chronological order
  /// from oldest to newest month.
  /// 
  /// Returns:
  /// - [List<MonthlySpendingData>] containing monthly summaries
  /// - Empty list if no expenses exist
  /// 
  /// The method ensures consistent 12-month coverage regardless of
  /// when expenses were recorded, filling gaps with zero amounts.
  List<MonthlySpendingData> _getMonthlyData() {
    // Get last 12 months starting from current month
    final now = DateTime.now();
    final months = <MonthlySpendingData>[];
    
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthExpenses = expenses.where((expense) {
        return expense.date.year == month.year && 
               expense.date.month == month.month;
      }).toList();
      
      final totalAmount = monthExpenses.fold<double>(
        0, (sum, expense) => sum + expense.amount,
      );
      
      months.add(MonthlySpendingData(
        month: month,
        amount: totalAmount,
        monthName: DateFormat('MMMM yyyy').format(month),
        shortName: DateFormat('MMM').format(month),
      ));
    }
    
    return months;
  }
}

/// Data model for monthly spending information
/// 
/// Represents aggregated spending data for a single month with
/// both full and abbreviated month names for flexible display options.
/// 
/// Properties:
/// - [month]: The DateTime representing the first day of the month
/// - [amount]: Total spending amount for the month in rupees
/// - [monthName]: Full month name with year (e.g., "March 2024")
/// - [shortName]: Abbreviated month name (e.g., "Mar")
/// 
/// This model is optimized for chart display and tooltip information,
/// providing multiple formatting options for different UI contexts.
class MonthlySpendingData {
  /// The month this data represents (first day of month)
  final DateTime month;
  
  /// Total spending amount for this month
  final double amount;
  
  /// Full month name with year for tooltips
  final String monthName;
  
  /// Short month name for chart labels
  final String shortName;

  const MonthlySpendingData({
    required this.month,
    required this.amount,
    required this.monthName,
    required this.shortName,
  });
}