// Category Tracker Chart Widget
// 
// Professional category-wise expense tracking with pie chart and detailed breakdown.
// Provides comprehensive visualization of spending patterns across different categories.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import 'gradient_container.dart';

/// Category tracker chart with pie chart and breakdown
class CategoryTrackerChart extends StatefulWidget {
  /// List of expenses to analyze
  final List<Expense> expenses;
  
  /// Whether to show detailed breakdown
  final bool showBreakdown;

  const CategoryTrackerChart({
    super.key,
    required this.expenses,
    this.showBreakdown = true,
  });

  @override
  State<CategoryTrackerChart> createState() => _CategoryTrackerChartState();
}

class _CategoryTrackerChartState extends State<CategoryTrackerChart>
    with SingleTickerProviderStateMixin {
  
  /// Animation controller for chart animations
  late AnimationController _animationController;
  
  /// Animation for pie chart sections
  late Animation<double> _pieAnimation;
  
  /// Currently touched section index
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pieAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryData = _getCategoryData();
    
    if (categoryData.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        
        // Pie Chart
        GradientContainer(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 280,
            child: AnimatedBuilder(
              animation: _pieAnimation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    sections: categoryData.map((data) => _buildPieSection(data, isDark)).toList(),
                    centerSpaceRadius: 60,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Category breakdown list
        if (widget.showBreakdown) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Detailed Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...categoryData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return _buildCategoryItem(data, index, isDark);
          }),
        ],
      ],
    );
  }

  /// Builds pie chart section
  PieChartSectionData _buildPieSection(CategoryData data, bool isDark) {
    final color = _getCategoryColor(data.category);
    final total = _getTotalAmount();
    final percentage = total > 0 ? (data.amount / total * 100) : 0;
    final isSelected = categoryData.indexOf(data) == touchedIndex;
    
    return PieChartSectionData(
      color: color,
      value: data.amount * _pieAnimation.value,
      title: '${percentage.toStringAsFixed(1)}%',
      radius: isSelected ? 70 : 60,
      titleStyle: TextStyle(
        fontSize: isSelected ? 14 : 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 2,
          ),
        ],
      ),
      titlePositionPercentageOffset: 0.6,
    );
  }

  /// Builds category item in breakdown list
  Widget _buildCategoryItem(CategoryData data, int index, bool isDark) {
    final color = _getCategoryColor(data.category);
    final total = _getTotalAmount();
    final percentage = total > 0 ? (data.amount / total * 100) : 0;
    final icon = _getCategoryIcon(data.category);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category icon and color indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(data.amount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${data.count} transaction${data.count != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark 
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state when no expenses
  Widget _buildEmptyState(bool isDark) {
    return GradientContainer(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'No Category Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Add some expenses to see category breakdown',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark 
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets category data from expenses
  List<CategoryData> get categoryData => _getCategoryData();

  List<CategoryData> _getCategoryData() {
    final Map<String, CategoryData> categoryMap = {};
    
    for (final expense in widget.expenses) {
      if (categoryMap.containsKey(expense.category)) {
        categoryMap[expense.category] = CategoryData(
          category: expense.category,
          amount: categoryMap[expense.category]!.amount + expense.amount,
          count: categoryMap[expense.category]!.count + 1,
        );
      } else {
        categoryMap[expense.category] = CategoryData(
          category: expense.category,
          amount: expense.amount,
          count: 1,
        );
      }
    }
    
    // Sort by amount (highest first)
    final sortedData = categoryMap.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    return sortedData;
  }

  /// Gets total amount across all categories
  double _getTotalAmount() {
    return widget.expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  /// Gets color for category
  Color _getCategoryColor(String category) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF84CC16), // Lime
      const Color(0xFFEC4899), // Pink
    ];
    
    final index = AppConstants.expenseCategories.indexOf(category);
    return colors[index % colors.length];
  }

  /// Gets icon for category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'other':
        return Icons.category_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }
}

/// Data class for category information
class CategoryData {
  final String category;
  final double amount;
  final int count;

  const CategoryData({
    required this.category,
    required this.amount,
    required this.count,
  });
}

/// Compact category tracker for smaller spaces
class CompactCategoryTracker extends StatelessWidget {
  /// List of expenses to analyze
  final List<Expense> expenses;
  
  /// Maximum number of categories to show
  final int maxCategories;

  const CompactCategoryTracker({
    super.key,
    required this.expenses,
    this.maxCategories = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryData = _getCategoryData();
    
    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    return GradientContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.donut_small_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...categoryData.take(maxCategories).map((data) {
            final color = _getCategoryColor(data.category);
            final total = _getTotalAmount();
            final percentage = total > 0 ? (data.amount / total * 100) : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Text(
                      data.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Gets category data from expenses
  List<CategoryData> _getCategoryData() {
    final Map<String, CategoryData> categoryMap = {};
    
    for (final expense in expenses) {
      if (categoryMap.containsKey(expense.category)) {
        categoryMap[expense.category] = CategoryData(
          category: expense.category,
          amount: categoryMap[expense.category]!.amount + expense.amount,
          count: categoryMap[expense.category]!.count + 1,
        );
      } else {
        categoryMap[expense.category] = CategoryData(
          category: expense.category,
          amount: expense.amount,
          count: 1,
        );
      }
    }
    
    // Sort by amount (highest first)
    final sortedData = categoryMap.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    return sortedData;
  }

  /// Gets total amount across all categories
  double _getTotalAmount() {
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  /// Gets color for category
  Color _getCategoryColor(String category) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
    ];
    
    final index = AppConstants.expenseCategories.indexOf(category);
    return colors[index % colors.length];
  }
}