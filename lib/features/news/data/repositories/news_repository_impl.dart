// News Repository Implementation
// 
// Data layer implementation of the NewsRepository interface.
// This class coordinates between the remote data source and domain layer,
// handling data transformation, error management, and caching.
// 
// Key Responsibilities:
// - Implement domain repository interface
// - Coordinate with remote data sources
// - Transform data models to domain entities
// - Handle caching and offline scenarios
// - Manage error propagation
// 
// Features:
// - Clean Architecture compliance
// - Comprehensive error handling
// - Data transformation
// - Automatic caching integration
// - Four news categories support
// 
// Usage:
// ```dart
// final repository = NewsRepositoryImpl(remoteDataSource);
// final articles = await repository.getLatestNews();
// ```

import 'package:flutter/foundation.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

/// Implementation of NewsRepository interface
/// 
/// Provides concrete implementation of news data operations by coordinating
/// with remote data sources and transforming data between layers.
class NewsRepositoryImpl implements NewsRepository {
  /// Remote data source for fetching news from external APIs
  final NewsRemoteDataSource remoteDataSource;

  /// Creates a NewsRepositoryImpl with required dependencies
  /// 
  /// [remoteDataSource] Data source for external news API operations
  const NewsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<NewsArticle>> getLatestNews({
    bool forceRefresh = false,
    String? category,
    String? country,
  }) async {
    try {
      // Fetch data from remote source
      final articleModels = await remoteDataSource.getLatestNews(
        forceRefresh: forceRefresh,
        category: category,
        country: country,
      );

      // Transform models to domain entities
      final articles = _transformModelsToEntities(articleModels);

      return articles;
    } catch (e) {
      // Re-throw domain exceptions as-is
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions in domain exception
      throw NewsException(
        'Failed to fetch latest news',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NewsArticle>> getCryptoNews({
    bool forceRefresh = false,
  }) async {
    try {
      // Fetch data from remote source
      final articleModels = await remoteDataSource.getCryptoNews(
        forceRefresh: forceRefresh,
      );

      // Transform models to domain entities
      final articles = _transformModelsToEntities(articleModels);

      return articles;
    } catch (e) {
      // Re-throw domain exceptions as-is
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions in domain exception
      throw NewsException(
        'Failed to fetch crypto news',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NewsArticle>> getMarketNews({
    bool forceRefresh = false,
  }) async {
    try {
      // Fetch data from remote source
      final articleModels = await remoteDataSource.getMarketNews(
        forceRefresh: forceRefresh,
      );

      // Transform models to domain entities
      final articles = _transformModelsToEntities(articleModels);

      return articles;
    } catch (e) {
      // Re-throw domain exceptions as-is
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions in domain exception
      throw NewsException(
        'Failed to fetch market news',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNewsSources({
    bool forceRefresh = false,
    String? category,
    String? country,
  }) async {
    try {
      // Fetch data from remote source
      final sources = await remoteDataSource.getNewsSources(
        forceRefresh: forceRefresh,
        category: category,
        country: country,
      );

      return sources;
    } catch (e) {
      // Re-throw domain exceptions as-is
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions in domain exception
      throw NewsException(
        'Failed to fetch news sources',
        originalError: e,
      );
    }
  }

  @override
  Future<List<NewsArticle>> searchNews(
    String query, {
    bool forceRefresh = false,
    String? category,
  }) async {
    try {
      // Validate search query
      _validateSearchQuery(query);

      // Fetch data from remote source
      final articleModels = await remoteDataSource.searchNews(
        query,
        forceRefresh: forceRefresh,
        category: category,
      );

      // Transform models to domain entities
      final articles = _transformModelsToEntities(articleModels);

      return articles;
    } catch (e) {
      // Re-throw domain exceptions as-is
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions in domain exception
      throw NewsException(
        'Failed to search news with query: $query',
        originalError: e,
      );
    }
  }

  /// Transforms a list of data models to domain entities
  /// 
  /// Handles the conversion from data layer models to domain entities
  /// with proper error handling for individual articles.
  List<NewsArticle> _transformModelsToEntities(
    List<dynamic> articleModels,
  ) {
    final articles = <NewsArticle>[];

    for (final model in articleModels) {
      try {
        // Convert model to entity
        final article = model.toEntity();
        articles.add(article);
      } catch (e) {
        // Log the error but continue processing other articles
        // In production, you might want to use a proper logging service
        debugPrint('Warning: Failed to convert article model to entity: $e');
        continue;
      }
    }

    return articles;
  }

  /// Validates search query parameter
  /// 
  /// Ensures the search query meets basic requirements.
  void _validateSearchQuery(String query) {
    if (query.trim().isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }

    if (query.trim().length < 2) {
      throw ArgumentError('Search query must be at least 2 characters long');
    }

    if (query.length > 500) {
      throw ArgumentError('Search query cannot exceed 500 characters');
    }
  }
}