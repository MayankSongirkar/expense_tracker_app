/// Get Market News Use Case
/// 
/// Domain layer use case for fetching market and finance news articles.
/// This use case encapsulates the business logic for retrieving
/// and processing market-related news data.
/// 
/// Key Responsibilities:
/// - Fetch market news from repository with caching
/// - Apply business rules and validation
/// - Handle errors and edge cases
/// - Return processed market articles
/// 
/// Business Rules:
/// - Filter out articles without titles
/// - Sort by publication date (newest first)
/// - Validate article URLs
/// - Focus on market and finance content
/// 
/// Usage:
/// ```dart
/// final getMarketNews = GetMarketNews(newsRepository);
/// final articles = await getMarketNews(forceRefresh: true);
/// ```

import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

/// Use case for fetching market and finance news articles
/// 
/// Encapsulates the business logic for retrieving market-specific news
/// with proper error handling and data validation.
class GetMarketNews {
  /// News repository dependency
  final NewsRepository repository;

  /// Creates a GetMarketNews use case with required dependencies
  /// 
  /// [repository] Repository for news data operations
  const GetMarketNews(this.repository);

  /// Executes the use case to fetch market news
  /// 
  /// Fetches market and finance news articles from the repository and applies
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
  ///   final articles = await getMarketNews(forceRefresh: false);
  ///   print('Successfully fetched ${articles.length} market articles');
  /// } catch (e) {
  ///   print('Failed to fetch market news: $e');
  /// }
  /// ```
  Future<List<NewsArticle>> call({
    bool forceRefresh = false,
  }) async {
    try {
      // Fetch articles from repository
      final articles = await repository.getMarketNews(
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
        'Failed to fetch market news',
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
  /// - Prioritize market-specific keywords
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

    // Further sort by market relevance
    return _sortByMarketRelevance(processedArticles);
  }

  /// Sorts articles by market relevance
  /// 
  /// Articles with market-specific keywords in title get higher priority
  List<NewsArticle> _sortByMarketRelevance(List<NewsArticle> articles) {
    const marketKeywords = {
      'stock', 'market', 'trading', 'investment', 'finance', 'economy',
      'earnings', 'revenue', 'profit', 'loss', 'shares', 'dividend',
      'ipo', 'nasdaq', 'dow', 'sp500', 'bull', 'bear', 'volatility',
      'inflation', 'interest', 'fed', 'bank', 'financial', 'analyst'
    };

    return articles..sort((a, b) {
      final aScore = _calculateMarketScore(a, marketKeywords);
      final bScore = _calculateMarketScore(b, marketKeywords);
      
      if (aScore != bScore) {
        return bScore.compareTo(aScore); // Higher score first
      }
      
      // If same score, sort by date
      return b.publishedAt.compareTo(a.publishedAt);
    });
  }

  /// Calculates market relevance score for an article
  int _calculateMarketScore(NewsArticle article, Set<String> keywords) {
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