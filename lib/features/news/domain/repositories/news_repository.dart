/// News Repository Interface
/// 
/// Domain layer repository interface that defines the contract for news data operations.
/// This interface is implemented by the data layer and used by use cases.
/// 
/// Following Clean Architecture principles:
/// - Domain layer defines the interface
/// - Data layer provides the implementation
/// - Use cases depend on this abstraction
/// 
/// Features:
/// - Financial news fetching
/// - Category-based filtering
/// - Search functionality
/// - Error handling
/// 
/// Usage:
/// ```dart
/// final articles = await newsRepository.getFinanceNews();
/// final searchResults = await newsRepository.searchNews('bitcoin');
/// ```

import '../entities/news_article.dart';

/// Abstract repository interface for news operations
/// 
/// Defines the contract for fetching news from external sources with
/// support for multiple news categories and caching.
abstract class NewsRepository {
  /// Fetches the latest news articles
  /// 
  /// Returns a list of [NewsArticle] objects containing the latest
  /// news from various sources with automatic caching.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// - [category]: Optional category filter (business, technology, etc.)
  /// - [country]: Optional country filter (us, in, gb, etc.)
  /// 
  /// Example:
  /// ```dart
  /// final articles = await repository.getLatestNews(
  ///   category: 'business',
  ///   country: 'in',
  /// );
  /// ```
  Future<List<NewsArticle>> getLatestNews({
    bool forceRefresh = false,
    String? category,
    String? country,
  });

  /// Fetches cryptocurrency-specific news
  /// 
  /// Returns articles specifically related to cryptocurrencies,
  /// blockchain technology, and digital assets.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// 
  /// Example:
  /// ```dart
  /// final cryptoNews = await repository.getCryptoNews();
  /// ```
  Future<List<NewsArticle>> getCryptoNews({
    bool forceRefresh = false,
  });

  /// Fetches market and finance news
  /// 
  /// Returns articles related to financial markets, stocks,
  /// economic indicators, and business developments.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// 
  /// Example:
  /// ```dart
  /// final marketNews = await repository.getMarketNews();
  /// ```
  Future<List<NewsArticle>> getMarketNews({
    bool forceRefresh = false,
  });

  /// Fetches available news sources
  /// 
  /// Returns information about available news sources including
  /// their categories, countries, and other metadata.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// - [category]: Optional category filter
  /// - [country]: Optional country filter
  /// 
  /// Example:
  /// ```dart
  /// final sources = await repository.getNewsSources(
  ///   category: 'business',
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> getNewsSources({
    bool forceRefresh = false,
    String? category,
    String? country,
  });

  /// Searches for news articles based on query
  /// 
  /// Returns articles that match the search query with caching support.
  /// 
  /// Parameters:
  /// - [query]: Search term or phrase
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// - [category]: Optional category filter
  /// 
  /// Example:
  /// ```dart
  /// final results = await repository.searchNews(
  ///   'cryptocurrency market',
  ///   category: 'business',
  /// );
  /// ```
  Future<List<NewsArticle>> searchNews(
    String query, {
    bool forceRefresh = false,
    String? category,
  });
}

/// Exception thrown when news operations fail
class NewsException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const NewsException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'NewsException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when network operations fail
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() {
    return 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}