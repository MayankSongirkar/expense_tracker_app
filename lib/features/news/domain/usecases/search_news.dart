// Search News Use Case
// 
// Domain layer use case for searching news articles based on user queries.
// This use case handles the business logic for news search functionality
// with proper validation and filtering.
// 
// Key Responsibilities:
// - Validate search queries
// - Execute search through repository
// - Apply business rules to results
// - Handle search-specific errors
// 
// Business Rules:
// - Minimum query length of 2 characters
// - Filter inappropriate content
// - Sort by relevance and date
// - Limit results for performance
// 
// Usage:
// ```dart
// final searchNews = SearchNews(newsRepository);
// final results = await searchNews('cryptocurrency market');
// ```

import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

/// Use case for searching news articles
/// 
/// Encapsulates the business logic for searching news articles
/// with query validation and result processing.
class SearchNews {
  /// News repository dependency
  final NewsRepository repository;

  /// Creates a SearchNews use case with required dependencies
  /// 
  /// [repository] Repository for news data operations
  const SearchNews(this.repository);

  /// Executes the search use case
  /// 
  /// Searches for news articles matching the provided query and applies
  /// business rules for validation and filtering.
  /// 
  /// Parameters:
  /// - [query]: Search term or phrase (minimum 2 characters)
  /// 
  /// Returns a list of [NewsArticle] objects matching the search criteria
  /// 
  /// Throws:
  /// - [ArgumentError] if query is too short or invalid
  /// - [NewsException] if the search fails
  /// - [NetworkException] if there's no internet connection
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final results = await searchNews('bitcoin price analysis');
  ///   debugPrint('Found ${results.length} articles');
  /// } catch (e) {
  ///   debugPrint('Search failed: $e');
  /// }
  /// ```
  Future<List<NewsArticle>> call(String query) async {
    // Validate search query
    final cleanQuery = _validateAndCleanQuery(query);

    try {
      // Execute search through repository
      final articles = await repository.searchNews(cleanQuery);

      // Process and filter results
      final processedArticles = _processSearchResults(articles, cleanQuery);

      return processedArticles;
    } catch (e) {
      // Re-throw known exceptions
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions
      throw NewsException(
        'Failed to search news articles',
        originalError: e,
      );
    }
  }

  /// Validates and cleans the search query
  /// 
  /// Business rules:
  /// - Minimum length of 2 characters
  /// - Remove excessive whitespace
  /// - Filter inappropriate terms
  /// - Convert to lowercase for consistency
  String _validateAndCleanQuery(String query) {
    if (query.trim().isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }

    final cleanQuery = query.trim();
    
    if (cleanQuery.length < 2) {
      throw ArgumentError('Search query must be at least 2 characters long');
    }

    if (cleanQuery.length > 100) {
      throw ArgumentError('Search query cannot exceed 100 characters');
    }

    // Check for inappropriate content (basic filter)
    if (_containsInappropriateContent(cleanQuery)) {
      throw ArgumentError('Search query contains inappropriate content');
    }

    return cleanQuery;
  }

  /// Processes search results according to business rules
  /// 
  /// Processing includes:
  /// - Filtering invalid articles
  /// - Removing duplicates
  /// - Sorting by relevance and date
  /// - Applying content filters
  List<NewsArticle> _processSearchResults(
    List<NewsArticle> articles,
    String query,
  ) {
    return articles
        // Filter out invalid articles
        .where((article) => _isValidSearchResult(article, query))
        // Remove duplicates based on URL
        .fold<List<NewsArticle>>([], (unique, article) {
          if (!unique.any((existing) => existing.url == article.url)) {
            unique.add(article);
          }
          return unique;
        })
        // Sort by relevance and date
        .toList()
      ..sort((a, b) => _compareRelevance(a, b, query));
  }

  /// Validates if an article is a valid search result
  /// 
  /// An article is valid if:
  /// - It meets basic article validation criteria
  /// - It's relevant to the search query
  /// - It doesn't contain inappropriate content
  bool _isValidSearchResult(NewsArticle article, String query) {
    // Basic article validation
    if (article.title.trim().isEmpty || !_isValidUrl(article.url)) {
      return false;
    }

    // Check relevance to query
    if (!_isRelevantToQuery(article, query)) {
      return false;
    }

    // Content appropriateness check
    if (_containsInappropriateContent(article.title) ||
        _containsInappropriateContent(article.description ?? '')) {
      return false;
    }

    return true;
  }

  /// Checks if an article is relevant to the search query
  bool _isRelevantToQuery(NewsArticle article, String query) {
    final queryLower = query.toLowerCase();
    final titleLower = article.title.toLowerCase();
    final descriptionLower = (article.description ?? '').toLowerCase();

    // Check if query terms appear in title or description
    final queryWords = queryLower.split(' ').where((word) => word.length > 1);
    
    for (final word in queryWords) {
      if (titleLower.contains(word) || descriptionLower.contains(word)) {
        return true;
      }
    }

    return false;
  }

  /// Compares articles for relevance sorting
  /// 
  /// Sorting criteria:
  /// 1. Title relevance (exact matches first)
  /// 2. Description relevance
  /// 3. Publication date (newer first)
  int _compareRelevance(NewsArticle a, NewsArticle b, String query) {
    final queryLower = query.toLowerCase();
    
    // Check title relevance
    final aTitleRelevance = _calculateRelevanceScore(a.title, queryLower);
    final bTitleRelevance = _calculateRelevanceScore(b.title, queryLower);
    
    if (aTitleRelevance != bTitleRelevance) {
      return bTitleRelevance.compareTo(aTitleRelevance);
    }

    // Check description relevance
    final aDescRelevance = _calculateRelevanceScore(a.description ?? '', queryLower);
    final bDescRelevance = _calculateRelevanceScore(b.description ?? '', queryLower);
    
    if (aDescRelevance != bDescRelevance) {
      return bDescRelevance.compareTo(aDescRelevance);
    }

    // Sort by date (newer first)
    return b.publishedAt.compareTo(a.publishedAt);
  }

  /// Calculates relevance score for text against query
  int _calculateRelevanceScore(String text, String query) {
    final textLower = text.toLowerCase();
    int score = 0;

    // Exact phrase match gets highest score
    if (textLower.contains(query)) {
      score += 10;
    }

    // Individual word matches
    final queryWords = query.split(' ').where((word) => word.length > 1);
    for (final word in queryWords) {
      if (textLower.contains(word)) {
        score += 1;
      }
    }

    return score;
  }

  /// Basic inappropriate content filter
  bool _containsInappropriateContent(String text) {
    // This is a basic implementation - in production, you'd use a more
    // sophisticated content filtering service
    final inappropriateTerms = [
      // Add inappropriate terms as needed
      'spam',
      'scam',
    ];

    final textLower = text.toLowerCase();
    return inappropriateTerms.any((term) => textLower.contains(term));
  }

  /// Validates if a URL is properly formatted
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

/// Parameters for the SearchNews use case
class SearchNewsParams {
  final String query;
  final int page;
  final int pageSize;

  const SearchNewsParams({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  String toString() => 'SearchNewsParams(query: $query, page: $page, pageSize: $pageSize)';
}