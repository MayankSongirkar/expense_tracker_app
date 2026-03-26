/// Live Finance News Screen
/// 
/// Presentation layer screen for displaying financial news articles with
/// four different categories: Latest, Crypto, Market, and Sources.
/// This screen provides a comprehensive news reading experience with
/// tabbed navigation, search functionality, and caching.
/// 
/// Key Features:
/// - Four news categories with dedicated tabs
/// - Real-time financial news from NewsData.io API
/// - Search functionality with query validation
/// - Pull-to-refresh for latest updates
/// - Professional Material 3 design
/// - Error handling with retry options
/// - Analytics tracking for user interactions
/// - Automatic caching for improved performance
/// 
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const NewsScreen()),
/// );
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/news_article.dart';
import '../providers/news_provider.dart';
import '../widgets/news_article_card.dart';
import '../widgets/news_search_bar.dart';
import '../widgets/news_error_widget.dart';
import '../widgets/news_loading_widget.dart';

/// Main screen for displaying financial news with four categories
/// 
/// Provides a comprehensive news reading experience with tabbed navigation
/// and modern UI/UX design.
class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen>
    with TickerProviderStateMixin {
  
  /// Tab controller for managing news categories
  late TabController _tabController;
  
  /// Search controller for query input
  final TextEditingController _searchController = TextEditingController();
  
  /// Focus node for search input
  final FocusNode _searchFocusNode = FocusNode();
  
  /// Animation controller for screen transitions
  late AnimationController _animationController;
  
  /// Fade animation for content
  late Animation<double> _fadeAnimation;
  
  /// Slide animation for search bar
  late Animation<Offset> _slideAnimation;

  /// News categories with their labels and icons
  final List<NewsCategory> _categories = [
    NewsCategory(
      key: 'latest',
      label: 'Latest',
      icon: Icons.newspaper_rounded,
      description: 'Latest news from all sources',
    ),
    NewsCategory(
      key: 'crypto',
      label: 'Crypto',
      icon: Icons.currency_bitcoin_rounded,
      description: 'Cryptocurrency and blockchain news',
    ),
    NewsCategory(
      key: 'market',
      label: 'Market',
      icon: Icons.trending_up_rounded,
      description: 'Financial markets and trading news',
    ),
    NewsCategory(
      key: 'sources',
      label: 'Sources',
      icon: Icons.source_rounded,
      description: 'News sources information',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Listen to tab changes
    _tabController.addListener(_onTabChanged);
    
    // Load initial news data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNews();
    });
    
    // Start animations
    _animationController.forward();
    
    // Log screen view for analytics
    AnalyticsService.logScreenView('news');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Handles tab changes
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final category = _categories[_tabController.index];
      
      // Log tab change analytics
      AnalyticsService.logFeatureUsage(
        'news',
        'tab_change',
        parameters: <String, Object>{
          'category': category.key,
        },
      );
      
      // Load data for the selected category
      _loadCategoryNews(category.key);
    }
  }

  /// Loads initial news data for the first tab
  void _loadInitialNews() {
    final firstCategory = _categories[0];
    _loadCategoryNews(firstCategory.key);
  }

  /// Loads news for a specific category
  void _loadCategoryNews(String categoryKey) {
    final newsNotifier = ref.read(newsProvider.notifier);
    
    switch (categoryKey) {
      case 'latest':
        newsNotifier.loadLatestNews(refresh: true);
        break;
      case 'crypto':
        newsNotifier.loadCryptoNews(refresh: true);
        break;
      case 'market':
        newsNotifier.loadMarketNews(refresh: true);
        break;
      case 'sources':
        newsNotifier.loadNewsSources(refresh: true);
        break;
    }
  }

  /// Handles search submission
  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _searchFocusNode.unfocus();
      ref.read(newsProvider.notifier).searchArticles(query.trim());
      
      // Log search analytics
      AnalyticsService.logFeatureUsage(
        'news',
        'search',
        parameters: <String, Object>{
          'query_length': query.trim().length,
        },
      );
    }
  }

  /// Handles search clear
  void _onSearchCleared() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(newsProvider.notifier).clearSearch();
    
    // Reload current category
    final currentCategory = _categories[_tabController.index];
    _loadCategoryNews(currentCategory.key);
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    final currentCategory = _categories[_tabController.index];
    _loadCategoryNews(currentCategory.key);
  }

  /// Handles article tap
  void _onArticleTapped(NewsArticle article) {
    // Log article view analytics
    AnalyticsService.logFeatureUsage(
      'news',
      'article_view',
      parameters: <String, Object>{
        'source': article.source.name,
        'has_image': article.hasImage ? 'true' : 'false', // Convert boolean to string
      },
    );
    
    // Open article URL
    _launchArticleUrl(article.url);
  }

  /// Launches article URL in browser
  Future<void> _launchArticleUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Check if the URL can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If URL can't be launched, show a more helpful message
        _showInfoSnackBar('Opening ${uri.host} in browser...');
        
        // Try alternative launch modes
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          _showErrorSnackBar('Unable to open this article. Please check your internet connection.');
        }
      }
    } catch (e) {
      // If URL parsing fails, show error
      _showErrorSnackBar('Invalid article link');
    }
  }

  /// Shows info snack bar
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search bar
            SlideTransition(
              position: _slideAnimation,
              child: NewsSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSubmitted: _onSearchSubmitted,
                onCleared: _onSearchCleared,
                isSearching: ref.watch(newsProvider).isSearching,
              ),
            ),
            
            // Tab bar
            _buildTabBar(isDark),
            
            // Content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildTabContent(category, isDark);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: SlideInAnimation.fromLeft(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.newspaper_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Finance News',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: isDark 
          ? const Color(0xFF0A0A0A).withValues(alpha: 0.95)
          : const Color(0xFFF8FAFC).withValues(alpha: 0.95),
      actions: [
        SlideInAnimation.fromRight(
          delay: const Duration(milliseconds: 200),
          child: IconButton(
            onPressed: _onRefresh,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            tooltip: 'Refresh News',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _categories.map((category) {
          return Tab(
            icon: Icon(category.icon, size: 20),
            text: category.label,
          );
        }).toList(),
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: isDark 
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds content for each tab
  Widget _buildTabContent(NewsCategory category, bool isDark) {
    final newsState = ref.watch(newsProvider);

    if (newsState.isLoading && !newsState.hasArticles) {
      return NewsLoadingWidget(
        type: category.key == 'sources' 
            ? NewsLoadingType.sources 
            : NewsLoadingType.articles,
      );
    }

    if (newsState.hasError && !newsState.hasArticles) {
      return NewsErrorWidget(
        error: newsState.error!,
        onRetry: () {
          ref.read(newsProvider.notifier).clearError();
          _loadCategoryNews(category.key);
        },
      );
    }

    if (!newsState.hasArticles) {
      return _buildEmptyState(category, isDark);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryColor,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsState.articles.length + (newsState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < newsState.articles.length) {
            final article = newsState.articles[index];
            return SlideInAnimation.fromBottom(
              delay: Duration(milliseconds: index * 50),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NewsArticleCard(
                  article: article,
                  onTap: () => _onArticleTapped(article),
                ),
              ),
            );
          } else {
            // Loading indicator for pagination
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState(NewsCategory category, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${category.label} Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadCategoryNews(category.key),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// News category data class
class NewsCategory {
  final String key;
  final String label;
  final IconData icon;
  final String description;

  const NewsCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.description,
  });
}