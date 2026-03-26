import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/widgets/animated_fab.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/analytics_service.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'expense_list_screen.dart';
import 'analytics_screen.dart';
import 'add_expense_screen.dart';
import '../../../news/presentation/screens/news_screen.dart';

/// Main screen with bottom navigation
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExpenseListScreen(),
    const AnalyticsScreen(),
    const NewsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Log screen view for analytics
    AnalyticsService.logScreenView('main_screen');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: SlideInAnimation.fromLeft(
          child: Text(
            _getAppBarTitle(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
          ),
        ),
        actions: [
          SlideInAnimation.fromRight(
            delay: const Duration(milliseconds: 200),
            child: BounceAnimation(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: SlideInAnimation.fromBottom(
        delay: const Duration(milliseconds: 600),
        child: AnimatedSpeedDial(
          icon: Icons.add_rounded,
          activeIcon: Icons.close_rounded,
          tooltip: 'Add Expense',
          actions: [
            SpeedDialAction(
              icon: Icons.receipt_long_outlined,
              label: 'Quick Expense',
              onPressed: () {
                Navigator.push(
                  context,
                  FadeScalePageRoute(
                    child: const AddExpenseScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
            ),
            SpeedDialAction(
              icon: Icons.camera_alt_outlined,
              label: 'Scan Receipt',
              onPressed: () {
                // TODO: Implement receipt scanning
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Receipt scanning coming soon!'),
                    backgroundColor: AppTheme.accentColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.accentColor,
            ),
            SpeedDialAction(
              icon: Icons.voice_chat_outlined,
              label: 'Voice Entry',
              onPressed: () {
                // TODO: Implement voice entry
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Voice entry coming soon!'),
                    backgroundColor: AppTheme.secondaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.secondaryColor,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Expenses';
      case 2:
        return 'Analytics';
      case 3:
        return 'Finance News';
      default:
        return 'Smart Expense Tracker';
    }
  }

  /// Builds a modern Material 3 bottom navigation bar
  /// 
  /// Features:
  /// - Smooth animations and transitions
  /// - Proper Material 3 design tokens
  /// - Accessibility support
  /// - Professional visual feedback
  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SlideInAnimation.fromBottom(
      delay: const Duration(milliseconds: 400),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF1E1E1E).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                outlinedIcon: Icons.dashboard_outlined,
                label: 'Dashboard',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_rounded,
                outlinedIcon: Icons.receipt_long_outlined,
                label: 'Expenses',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.analytics_rounded,
                outlinedIcon: Icons.analytics_outlined,
                label: 'Analytics',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.newspaper_rounded,
                outlinedIcon: Icons.newspaper_outlined,
                label: 'News',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item with smooth animations
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData outlinedIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });
              
              // Log screen navigation for analytics
              final screenNames = ['dashboard', 'expense_list', 'analytics', 'news'];
              AnalyticsService.logScreenView(screenNames[index]);
              
              // Haptic feedback for better UX
              HapticFeedback.lightImpact();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 85,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with animated background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isSelected ? icon : outlinedIcon,
                      key: ValueKey(isSelected),
                      size: 26,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Label with smooth color transition
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}