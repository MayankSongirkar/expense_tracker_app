import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../expenses/presentation/screens/main_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/analytics_service.dart';

/// Simple onboarding screen for first-time users
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Log screen view for analytics
    AnalyticsService.logScreenView('onboarding');
  }

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Smart Expense Tracker',
      description: 'Take control of your finances with our easy-to-use expense tracking app built for Indian users.',
      icon: Icons.account_balance_wallet_rounded,
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'Track Expenses in Rupees',
      description: 'Add expenses quickly with Indian currency support, categories, dates, and notes.',
      icon: Icons.currency_rupee_rounded,
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      title: 'Generate PDF Receipts',
      description: 'Download professional PDF receipts for each expense with Indian numbering format.',
      icon: Icons.receipt_long_rounded,
      color: AppTheme.accentColor,
    ),
    OnboardingPage(
      title: 'Visualize Your Spending',
      description: 'See your spending patterns with beautiful charts and monthly analytics.',
      icon: Icons.analytics_rounded,
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                ),
              const Spacer(),
              if (_currentPage < _pages.length - 1)
                ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Next'),
                )
              else
                ElevatedButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Get Started'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final box = await Hive.openBox('settings');
    await box.put('isOnboardingCompleted', true);
    
    // Log onboarding completion for analytics
    await AnalyticsService.logOnboardingCompleted();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}