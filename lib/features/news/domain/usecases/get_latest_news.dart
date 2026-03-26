/// Get Latest News Use Case
/// 
/// Domain layer use case for fetching the latest news articles.
/// This use case encapsulates the business logic for retrieving
/// and processing current news data with caching support.
/// 
/// Key Responsibilities:
/// - Fetch latest news from repository with caching
/// - Apply business rules and validation
/// - Handle errors and edge cases
/// - Return processed news articles
/// 
/// Business Rules:
/// - Filter out articles without titles
/// - Sort by publication date (newest first)
/// - Validate article URLs
/// - Support category and country filtering
/// 
/// Usage:
/// ```dart
/// final getLatestNews = GetLatestNews(newsRepository);
/// final articles = await getLatestNews(category: 'business');
/// ```

import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

/// Use case for fetching the latest news articles
/// 
/// Encapsulates the business logic for retrieving current news
/// with proper error handling and data validation.
class GetLatestNews {
  /// News repository dependency
  final NewsRepository repository;

  /// Creates a GetLatestNews use case with required dependencies
  /// 
  /// [repository] Repository for news data operations
  const GetLatestNews(this.repository);

  /// Executes the use case to fetch latest news
  /// 
  /// Fetches the latest news articles from the repository and applies
  /// business rules for filtering and sorting.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// - [category]: Optional category filter (business, technology, etc.)
  /// - [country]: Optional country filter (us, in, gb, etc.)
  /// 
  /// Returns a list of validated and sorted [NewsArticle] objects
  /// 
  /// Throws:
  /// - [NewsException] if the request fails
  /// - [NetworkException] if there's no internet connection
  /// - [ArgumentError] if parameters are invalid
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final articles = await getLatestNews(
  ///     category: 'business',
  ///     country: 'in',
  ///   );
  ///   print('Successfully fetched ${articles.length} articles');
  /// } catch (e) {
  ///   print('Failed to fetch news: $e');
  /// }
  /// ```
  Future<List<NewsArticle>> call({
    bool forceRefresh = false,
    String? category,
    String? country,
  }) async {
    // Validate category if provided
    if (category != null) {
      _validateCategory(category);
    }

    // Validate country if provided
    if (country != null) {
      _validateCountry(country);
    }

    try {
      // Fetch articles from repository
      final articles = await repository.getLatestNews(
        forceRefresh: forceRefresh,
        category: category,
        country: country,
      );

      // Apply business rules
      final processedArticles = _processArticles(articles);

      return processedArticles;
    } catch (e) {
      // Re-throw known exceptions
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions
      throw NewsException(
        'Failed to fetch latest news',
        originalError: e,
      );
    }
  }

  /// Validates category parameter
  void _validateCategory(String category) {
    const validCategories = {
      'business',
      'entertainment', 
      'environment',
      'food',
      'health',
      'politics',
      'science',
      'sports',
      'technology',
      'top',
      'world',
    };

    if (!validCategories.contains(category.toLowerCase())) {
      throw ArgumentError(
        'Invalid category: $category. '
        'Valid categories: ${validCategories.join(', ')}',
      );
    }
  }

  /// Validates country parameter
  void _validateCountry(String country) {
    if (country.length != 2) {
      throw ArgumentError(
        'Country must be a 2-letter ISO code (e.g., "us", "in", "gb")',
      );
    }

    const supportedCountries = {
      'us', 'in', 'gb', 'ca', 'au', 'de', 'fr', 'jp', 'kr',
      'br', 'mx', 'it', 'es', 'ru', 'za', 'ng', 'eg', 'ae',
    };

    if (!supportedCountries.contains(country.toLowerCase())) {
      throw ArgumentError(
        'Unsupported country: $country. '
        'Supported countries: ${supportedCountries.join(', ')}',
      );
    }
  }

  /// Processes and validates articles according to business rules
  /// 
  /// Business rules applied:
  /// - Filter out articles without titles
  /// - Filter out articles with invalid URLs
  /// - Sort by publication date (newest first)
  /// - Remove duplicates based on URL
  List<NewsArticle> _processArticles(List<NewsArticle> articles) {
    return articles
        // Filter out invalid articles
        .where((article) => _isValidArticle(article))
        // Remove duplicates based on URL
        .fold<List<NewsArticle>>([], (unique, article) {
          if (!unique.any((existing) => existing.url == article.url)) {
            unique.add(article);
          }
          return unique;
        })
        // Sort by publication date (newest first)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  /// Validates if an article meets business requirements
  /// 
  /// An article is considered valid if:
  /// - It has a non-empty title
  /// - It has a valid URL
  /// - It has a publication date
  bool _isValidArticle(NewsArticle article) {
    // Must have a title
    if (article.title.trim().isEmpty) {
      return false;
    }

    // Must have a valid URL
    if (!_isValidUrl(article.url)) {
      return false;
    }

    // Must have a reasonable publication date (not in the future)
    if (article.publishedAt.isAfter(DateTime.now())) {
      return false;
    }

    return true;
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