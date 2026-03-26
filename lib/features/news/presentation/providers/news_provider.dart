// News State Management Provider
// 
// Presentation layer provider for managing news state using Riverpod.
// This provider handles all news-related state management including
// loading states, error handling, and data caching.
// 
// Key Responsibilities:
// - Manage news articles state
// - Handle loading and error states
// - Coordinate with use cases
// - Provide search functionality
// - Cache management
// 
// Features:
// - Reactive state management
// - Error handling with recovery
// - Search functionality
// - Pagination support
// - Analytics integration
// 
// Usage:
// ```dart
// final newsState = ref.watch(newsProvider);
// final newsNotifier = ref.read(newsProvider.notifier);
// await newsNotifier.loadFinanceNews();
// ```

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/usecases/get_latest_news.dart';
import '../../domain/usecases/get_crypto_news.dart';
import '../../domain/usecases/get_market_news.dart';
import '../../domain/usecases/get_news_sources.dart';
import '../../domain/usecases/search_news.dart';

/// Immutable state class for news management
/// 
/// Represents the current state of news data with loading states,
/// error information, and cached articles.
class NewsState {
  /// List of current news articles
  final List<NewsArticle> articles;
  
  /// List of news sources (for sources tab)
  final List<Map<String, dynamic>> sources;
  
  /// Loading state indicator
  final bool isLoading;
  
  /// Error message from the last failed operation
  final String? error;
  
  /// Current search query (if any)
  final String? searchQuery;
  
  /// Current news category
  final String currentCategory;
  
  /// Indicates if more articles can be loaded (pagination)
  final bool hasMore;
  
  /// Current page number for pagination
  final int currentPage;
  
  /// Last refresh timestamp
  final DateTime? lastRefresh;

  const NewsState({
    this.articles = const [],
    this.sources = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.currentCategory = 'latest',
    this.hasMore = true,
    this.currentPage = 1,
    this.lastRefresh,
  });

  /// Creates a new state instance with updated values
  NewsState copyWith({
    List<NewsArticle>? articles,
    List<Map<String, dynamic>>? sources,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? currentCategory,
    bool? hasMore,
    int? currentPage,
    DateTime? lastRefresh,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      sources: sources ?? this.sources,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      currentCategory: currentCategory ?? this.currentCategory,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }

  /// Checks if the state has any articles
  bool get hasArticles => articles.isNotEmpty;

  /// Checks if the state is in an error condition
  bool get hasError => error != null;

  /// Checks if currently searching
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  /// Gets the number of articles currently loaded
  int get articleCount => articles.length;

  @override
  String toString() {
    return 'NewsState(articles: ${articles.length}, isLoading: $isLoading, hasError: $hasError)';
  }
}

/// State notifier for news management operations
/// 
/// Handles all news-related business logic and state updates.
/// Uses dependency injection for use cases following Clean Architecture.
class NewsNotifier extends StateNotifier<NewsState> {
  // Use case dependencies
  final GetLatestNews getLatestNews;
  final GetCryptoNews getCryptoNews;
  final GetMarketNews getMarketNews;
  final GetNewsSources getNewsSources;
  final SearchNews searchNews;

  /// Page size for pagination
  static const int _pageSize = 20;

  NewsNotifier({
    required this.getLatestNews,
    required this.getCryptoNews,
    required this.getMarketNews,
    required this.getNewsSources,
    required this.searchNews,
  }) : super(const NewsState());

  /// Loads latest news articles
  /// 
  /// Fetches the latest news and updates the state.
  /// Handles loading states and error management.
  /// 
  /// Parameters:
  /// - [refresh]: Whether to refresh existing data (default: false)
  /// 
  /// Example:
  /// ```dart
  /// await newsNotifier.loadLatestNews(refresh: true);
  /// ```
  Future<void> loadLatestNews({bool refresh = false}) async {
    try {
      // Set loading state
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentCategory: 'latest',
      );

      // Fetch articles
      final newArticles = await getLatestNews(forceRefresh: refresh);

      // Log analytics event
      await AnalyticsService.logFeatureUsage(
        'news',
        'load_latest_news',
        parameters: <String, Object>{
          'article_count': newArticles.length,
          'refresh': refresh ? 'true' : 'false', // Convert boolean to string
        },
      );

      // Update state with new articles
      state = state.copyWith(
        articles: newArticles,
        isLoading: false,
        hasMore: newArticles.length >= _pageSize,
        currentPage: 1,
        lastRefresh: DateTime.now(),
        searchQuery: null,
      );

    } catch (e) {
      // Log error to Crashlytics
      await CrashlyticsService.logError(
        'Failed to load latest news',
        exception: e,
        stackTrace: StackTrace.current,
      );

      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Loads crypto news articles
  /// 
  /// Fetches cryptocurrency news and updates the state.
  /// 
  /// Parameters:
  /// - [refresh]: Whether to refresh existing data (default: false)
  Future<void> loadCryptoNews({bool refresh = false}) async {
    try {
      // Set loading state
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentCategory: 'crypto',
      );

      // Fetch articles
      final newArticles = await getCryptoNews(forceRefresh: refresh);

      // Log analytics event
      await AnalyticsService.logFeatureUsage(
        'news',
        'load_crypto_news',
        parameters: <String, Object>{
          'article_count': newArticles.length,
          'refresh': refresh ? 'true' : 'false', // Convert boolean to string
        },
      );

      // Update state with new articles
      state = state.copyWith(
        articles: newArticles,
        isLoading: false,
        hasMore: newArticles.length >= _pageSize,
        currentPage: 1,
        lastRefresh: DateTime.now(),
        searchQuery: null,
      );

    } catch (e) {
      // Log error to Crashlytics
      await CrashlyticsService.logError(
        'Failed to load crypto news',
        exception: e,
        stackTrace: StackTrace.current,
      );

      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Loads market news articles
  /// 
  /// Fetches market and finance news and updates the state.
  /// 
  /// Parameters:
  /// - [refresh]: Whether to refresh existing data (default: false)
  Future<void> loadMarketNews({bool refresh = false}) async {
    try {
      // Set loading state
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentCategory: 'market',
      );

      // Fetch articles
      final newArticles = await getMarketNews(forceRefresh: refresh);

      // Log analytics event
      await AnalyticsService.logFeatureUsage(
        'news',
        'load_market_news',
        parameters: <String, Object>{
          'article_count': newArticles.length,
          'refresh': refresh ? 'true' : 'false', // Convert boolean to string
        },
      );

      // Update state with new articles
      state = state.copyWith(
        articles: newArticles,
        isLoading: false,
        hasMore: newArticles.length >= _pageSize,
        currentPage: 1,
        lastRefresh: DateTime.now(),
        searchQuery: null,
      );

    } catch (e) {
      // Log error to Crashlytics
      await CrashlyticsService.logError(
        'Failed to load market news',
        exception: e,
        stackTrace: StackTrace.current,
      );

      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Loads news sources
  /// 
  /// Fetches news sources information and updates the state.
  /// 
  /// Parameters:
  /// - [refresh]: Whether to refresh existing data (default: false)
  Future<void> loadNewsSources({bool refresh = false}) async {
    try {
      // Set loading state
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentCategory: 'sources',
      );

      // Fetch sources
      final newSources = await getNewsSources(forceRefresh: refresh);

      // Log analytics event
      await AnalyticsService.logFeatureUsage(
        'news',
        'load_news_sources',
        parameters: <String, Object>{
          'source_count': newSources.length,
          'refresh': refresh ? 'true' : 'false', // Convert boolean to string
        },
      );

      // Update state with new sources
      state = state.copyWith(
        sources: newSources,
        articles: [], // Clear articles when showing sources
        isLoading: false,
        hasMore: false, // Sources don't have pagination
        currentPage: 1,
        lastRefresh: DateTime.now(),
        searchQuery: null,
      );

    } catch (e) {
      // Log error to Crashlytics
      await CrashlyticsService.logError(
        'Failed to load news sources',
        exception: e,
        stackTrace: StackTrace.current,
      );

      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Searches for news articles based on query
  /// 
  /// Performs a search operation and updates the state with results.
  /// 
  /// Parameters:
  /// - [query]: Search term or phrase
  /// - [loadMore]: Whether to load more results for existing search
  /// 
  /// Example:
  /// ```dart
  /// await newsNotifier.searchArticles('cryptocurrency market');
  /// ```
  Future<void> searchArticles(String query, {bool loadMore = false}) async {
    try {
      // Validate query
      if (query.trim().isEmpty) {
        throw ArgumentError('Search query cannot be empty');
      }

      // Set loading state
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      // Determine page number
      // final page = loadMore && state.searchQuery == query 
      //     ? state.currentPage 
      //     : 1;

      // Perform search
      final searchResults = await searchNews(query.trim());

      // Log analytics event
      await AnalyticsService.logSearch(
        searchTerm: query.trim(),
        resultCount: searchResults.length,
      );

      // Update state with search results
      state = state.copyWith(
        articles: searchResults,
        isLoading: false,
        searchQuery: query.trim(),
        hasMore: false, // Search doesn't support pagination yet
        currentPage: 1,
        lastRefresh: DateTime.now(),
      );

    } catch (e) {
      // Log error to Crashlytics
      await CrashlyticsService.logError(
        'Failed to search news articles',
        exception: e,
        stackTrace: StackTrace.current,
      );

      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Loads more articles (pagination)
  /// 
  /// Loads additional articles for the current view.
  /// 
  /// Example:
  /// ```dart
  /// await newsNotifier.loadMoreArticles();
  /// ```
  Future<void> loadMoreArticles() async {
    // Don't load more if already loading or no more articles available
    if (state.isLoading || !state.hasMore) {
      return;
    }

    try {
      if (state.isSearching) {
        // Search doesn't support pagination yet
        return;
      } else {
        // Load more based on current category
        switch (state.currentCategory) {
          case 'latest':
            await loadLatestNews();
            break;
          case 'crypto':
            await loadCryptoNews();
            break;
          case 'market':
            await loadMarketNews();
            break;
          case 'sources':
            // Sources don't have pagination
            break;
        }
      }
    } catch (e) {
      // Error handling is done in the respective methods
      rethrow;
    }
  }

  /// Refreshes current articles
  /// 
  /// Refreshes the current view based on category or search.
  /// 
  /// Example:
  /// ```dart
  /// await newsNotifier.refreshArticles();
  /// ```
  Future<void> refreshArticles() async {
    try {
      if (state.isSearching) {
        // Refresh search results
        await searchArticles(state.searchQuery!);
      } else {
        // Refresh based on current category
        switch (state.currentCategory) {
          case 'latest':
            await loadLatestNews(refresh: true);
            break;
          case 'crypto':
            await loadCryptoNews(refresh: true);
            break;
          case 'market':
            await loadMarketNews(refresh: true);
            break;
          case 'sources':
            await loadNewsSources(refresh: true);
            break;
        }
      }
    } catch (e) {
      // Error handling is done in the respective methods
      rethrow;
    }
  }

  /// Clears search results and returns to current category
  /// 
  /// Example:
  /// ```dart
  /// newsNotifier.clearSearch();
  /// ```
  void clearSearch() {
    state = state.copyWith(
      searchQuery: null,
      currentPage: 1,
      hasMore: true,
    );
    
    // Load current category if no articles or if we were searching
    if (!state.hasArticles || state.isSearching) {
      switch (state.currentCategory) {
        case 'latest':
          loadLatestNews(refresh: true);
          break;
        case 'crypto':
          loadCryptoNews(refresh: true);
          break;
        case 'market':
          loadMarketNews(refresh: true);
          break;
        case 'sources':
          loadNewsSources(refresh: true);
          break;
      }
    }
  }

  /// Clears error state
  /// 
  /// Example:
  /// ```dart
  /// newsNotifier.clearError();
  /// ```
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Gets user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    if (error is ArgumentError) {
      return error.message;
    }
    
    final errorString = error.toString();
    
    if (errorString.contains('NetworkException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (errorString.contains('rate_limited')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    
    if (errorString.contains('unauthorized')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    
    if (errorString.contains('server_error')) {
      return 'Server error. Please try again later.';
    }
    
    return 'Failed to load news. Please try again.';
  }
}

/// Riverpod provider for news state management
/// 
/// Creates and provides the NewsNotifier with all required dependencies.
/// Uses the service locator (sl) to inject use case dependencies.
final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>(
  (ref) => NewsNotifier(
    getLatestNews: sl<GetLatestNews>(),
    getCryptoNews: sl<GetCryptoNews>(),
    getMarketNews: sl<GetMarketNews>(),
    getNewsSources: sl<GetNewsSources>(),
    searchNews: sl<SearchNews>(),
  ),
);

/// Provider for checking if news data needs refresh
/// 
/// Returns true if the last refresh was more than 15 minutes ago.
final newsNeedsRefreshProvider = Provider<bool>((ref) {
  final newsState = ref.watch(newsProvider);
  
  if (newsState.lastRefresh == null) {
    return true;
  }
  
  final timeSinceRefresh = DateTime.now().difference(newsState.lastRefresh!);
  return timeSinceRefresh.inMinutes > 15;
});

/// Provider for filtered articles based on search
/// 
/// Returns articles filtered by the current search query.
final filteredArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final newsState = ref.watch(newsProvider);
  return newsState.articles;
});

/// Provider for news loading state
/// 
/// Returns true if news is currently being loaded.
final newsLoadingProvider = Provider<bool>((ref) {
  final newsState = ref.watch(newsProvider);
  return newsState.isLoading;
});

/// Provider for news error state
/// 
/// Returns the current error message if any.
final newsErrorProvider = Provider<String?>((ref) {
  final newsState = ref.watch(newsProvider);
  return newsState.error;
});