/// Get Crypto News Use Case
/// 
/// Domain layer use case for fetching cryptocurrency-specific news articles.
/// This use case encapsulates the business logic for retrieving
/// and processing crypto-related news data.
/// 
/// Key Responsibilities:
/// - Fetch crypto news from repository with caching
/// - Apply business rules and validation
/// - Handle errors and edge cases
/// - Return processed crypto articles
/// 
/// Business Rules:
/// - Filter out articles without titles
/// - Sort by publication date (newest first)
/// - Validate article URLs
/// - Focus on crypto-specific content
/// 
/// Usage:
/// ```dart
/// final getCryptoNews = GetCryptoNews(newsRepository);
/// final articles = await getCryptoNews(forceRefresh: true);
/// ```

import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

/// Use case for fetching cryptocurrency news articles
/// 
/// Encapsulates the business logic for retrieving crypto-specific news
/// with proper error handling and data validation.
class GetCryptoNews {
  /// News repository dependency
  final NewsRepository repository;

  /// Creates a GetCryptoNews use case with required dependencies
  /// 
  /// [repository] Repository for news data operations
  const GetCryptoNews(this.repository);

  /// Executes the use case to fetch crypto news
  /// 
  /// Fetches cryptocurrency news articles from the repository and applies
  /// business rules for filtering and sorting.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// 
  /// Returns a list of validated and sorted [NewsArticle] objects
  /// 
  /// Throws:
  /// - [NewsException] if the request fails
  /// - [NetworkException] if there's no internet connection
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final articles = await getCryptoNews(forceRefresh: false);
  ///   print('Successfully fetched ${articles.length} crypto articles');
  /// } catch (e) {
  ///   print('Failed to fetch crypto news: $e');
  /// }
  /// ```
  Future<List<NewsArticle>> call({
    bool forceRefresh = false,
  }) async {
    try {
      // Fetch articles from repository
      final articles = await repository.getCryptoNews(
        forceRefresh: forceRefresh,
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
        'Failed to fetch crypto news',
        originalError: e,
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
  /// - Prioritize crypto-specific keywords
  List<NewsArticle> _processArticles(List<NewsArticle> articles) {
    final processedArticles = articles
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

    // Further sort by crypto relevance
    return _sortByCryptoRelevance(processedArticles);
  }

  /// Sorts articles by crypto relevance
  /// 
  /// Articles with crypto-specific keywords in title get higher priority
  List<NewsArticle> _sortByCryptoRelevance(List<NewsArticle> articles) {
    const cryptoKeywords = {
      'bitcoin', 'btc', 'ethereum', 'eth', 'cryptocurrency', 'crypto',
      'blockchain', 'defi', 'nft', 'altcoin', 'mining', 'wallet',
      'exchange', 'trading', 'hodl', 'satoshi', 'coinbase', 'binance'
    };

    return articles..sort((a, b) {
      final aScore = _calculateCryptoScore(a, cryptoKeywords);
      final bScore = _calculateCryptoScore(b, cryptoKeywords);
      
      if (aScore != bScore) {
        return bScore.compareTo(aScore); // Higher score first
      }
      
      // If same score, sort by date
      return b.publishedAt.compareTo(a.publishedAt);
    });
  }

  /// Calculates crypto relevance score for an article
  int _calculateCryptoScore(NewsArticle article, Set<String> keywords) {
    final titleLower = article.title.toLowerCase();
    final descriptionLower = article.description?.toLowerCase() ?? '';
    
    int score = 0;
    
    for (final keyword in keywords) {
      if (titleLower.contains(keyword)) {
        score += 3; // Title matches are more important
      }
      if (descriptionLower.contains(keyword)) {
        score += 1; // Description matches
      }
    }
    
    return score;
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