import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'gradient_container.dart';

/// Welcome card for first-time users
class WelcomeCard extends StatelessWidget {
  final VoidCallback? onAddExpense;

  const WelcomeCard({super.key, this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Welcome to Smart Expense Tracker!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Start your financial journey by adding your first expense. Track spending in Indian Rupees with beautiful analytics.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add First Expense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureList(context),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.currency_rupee_rounded,
        text: 'Track expenses in Indian Rupees',
        color: AppTheme.secondaryColor,
      ),
      _FeatureItem(
        icon: Icons.receipt_long_rounded,
        text: 'Generate PDF receipts',
        color: AppTheme.accentColor,
      ),
      _FeatureItem(
        icon: Icons.analytics_rounded,
        text: 'Beautiful charts and insights',
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                feature.icon,
                size: 16,
                color: feature.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature.text,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.8)
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;
  final Color color;

  _FeatureItem({
    required this.icon,
    required this.text,
    required this.color,
  });
}