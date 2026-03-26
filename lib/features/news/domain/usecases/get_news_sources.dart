/// Get News Sources Use Case
/// 
/// Domain layer use case for fetching news sources information.
/// This use case encapsulates the business logic for retrieving
/// and processing news sources data.
/// 
/// Key Responsibilities:
/// - Fetch news sources from repository with caching
/// - Apply business rules and validation
/// - Handle errors and edge cases
/// - Return processed sources information
/// 
/// Business Rules:
/// - Filter out sources without names
/// - Sort by source reliability and popularity
/// - Validate source URLs
/// - Support category and country filtering
/// 
/// Usage:
/// ```dart
/// final getNewsSources = GetNewsSources(newsRepository);
/// final sources = await getNewsSources(category: 'business');
/// ```

import '../repositories/news_repository.dart';

/// Use case for fetching news sources information
/// 
/// Encapsulates the business logic for retrieving news sources
/// with proper error handling and data validation.
class GetNewsSources {
  /// News repository dependency
  final NewsRepository repository;

  /// Creates a GetNewsSources use case with required dependencies
  /// 
  /// [repository] Repository for news data operations
  const GetNewsSources(this.repository);

  /// Executes the use case to fetch news sources
  /// 
  /// Fetches news sources information from the repository and applies
  /// business rules for filtering and sorting.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// - [category]: Optional category filter (business, technology, etc.)
  /// - [country]: Optional country filter (us, in, gb, etc.)
  /// 
  /// Returns a list of validated and sorted source information
  /// 
  /// Throws:
  /// - [NewsException] if the request fails
  /// - [NetworkException] if there's no internet connection
  /// - [ArgumentError] if parameters are invalid
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final sources = await getNewsSources(
  ///     category: 'business',
  ///     country: 'in',
  ///   );
  ///   print('Successfully fetched ${sources.length} sources');
  /// } catch (e) {
  ///   print('Failed to fetch sources: $e');
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> call({
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
      // Fetch sources from repository
      final sources = await repository.getNewsSources(
        forceRefresh: forceRefresh,
        category: category,
        country: country,
      );

      // Apply business rules
      final processedSources = _processSources(sources);

      return processedSources;
    } catch (e) {
      // Re-throw known exceptions
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      
      // Wrap unknown exceptions
      throw NewsException(
        'Failed to fetch news sources',
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

  /// Processes and validates sources according to business rules
  /// 
  /// Business rules applied:
  /// - Filter out sources without names
  /// - Filter out sources with invalid URLs
  /// - Sort by reliability and popularity
  /// - Remove duplicates based on ID
  List<Map<String, dynamic>> _processSources(List<Map<String, dynamic>> sources) {
    return sources
        // Filter out invalid sources
        .where((source) => _isValidSource(source))
        // Remove duplicates based on ID or name
        .fold<List<Map<String, dynamic>>>([], (unique, source) {
          final id = source['id'] as String?;
          final name = source['name'] as String?;
          
          final isDuplicate = unique.any((existing) {
            final existingId = existing['id'] as String?;
            final existingName = existing['name'] as String?;
            return (id != null && existingId == id) ||
                   (name != null && existingName == name);
          });
          
          if (!isDuplicate) {
            unique.add(source);
          }
          return unique;
        })
        // Sort by name alphabetically
        .toList()
      ..sort((a, b) {
        final nameA = (a['name'] as String? ?? '').toLowerCase();
        final nameB = (b['name'] as String? ?? '').toLowerCase();
        return nameA.compareTo(nameB);
      });
  }

  /// Validates if a source meets business requirements
  /// 
  /// A source is considered valid if:
  /// - It has a non-empty name
  /// - It has a valid URL (if provided)
  bool _isValidSource(Map<String, dynamic> source) {
    // Must have a name
    final name = source['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      return false;
    }

    // If URL is provided, it must be valid
    final url = source['url'] as String?;
    if (url != null && !_isValidUrl(url)) {
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