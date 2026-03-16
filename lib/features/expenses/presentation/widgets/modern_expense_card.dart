import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';

/// Modern, professional expense card widget
class ModernExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final bool showShadow;

  const ModernExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.showShadow = true,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.flight_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      default:
        return Icons.category_rounded;
    }
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
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    final color = _getCategoryColor(category);
    return LinearGradient(
      colors: [
        color.withOpacity(0.1),
        color.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDark ? AppTheme.darkCardGradient : AppTheme.cardGradient,
        boxShadow: showShadow ? [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon with gradient background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _getCategoryGradient(expense.category),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getCategoryColor(expense.category).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Expense Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(expense.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              expense.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getCategoryColor(expense.category),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDark 
                                ? Colors.white.withOpacity(0.6)
                                : const Color(0xFF64748B),
                          ),
                          
                          const SizedBox(width: 4),
                          
                          Text(
                            DateFormat('MMM dd').format(expense.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark 
                                  ? Colors.white.withOpacity(0.6)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(expense.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    
                    if (expense.notes != null && expense.notes!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.note_rounded,
                          size: 12,
                          color: isDark 
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}