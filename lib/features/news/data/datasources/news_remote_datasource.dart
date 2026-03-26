// News Remote Data Source
// 
// Data layer component responsible for fetching news data from NewsData.io API.
// This class handles all HTTP requests, response parsing, error handling,
// and caching for news-related operations.
// 
// Key Responsibilities:
// - HTTP requests to NewsData.io endpoints
// - Response parsing and validation
// - Error handling and retry logic
// - API key management from .env file
// - Caching integration
// 
// Features:
// - Multiple NewsData.io endpoints support
// - Comprehensive error handling
// - Request timeout management
// - Automatic caching with TTL
// - Four news categories: Latest, Crypto, Market, Sources
// 
// Usage:
// ```dart
// final dataSource = NewsRemoteDataSource(httpClient);
// final articles = await dataSource.getLatestNews();
// ```

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';
import '../../domain/repositories/news_repository.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/cache_service.dart';
import 'news_mock_datasource.dart';

/// Remote data source for fetching news from NewsData.io API
/// 
/// Handles all external API communications for news data with caching.
class NewsRemoteDataSource {
  /// HTTP client for making requests
  final http.Client httpClient;
  
  /// Cache service for storing responses
  final CacheService _cache = CacheService.instance;

  /// Creates a NewsRemoteDataSource with HTTP client dependency
  NewsRemoteDataSource(this.httpClient);

  /// Fetches latest news articles from NewsData.io
  /// 
  /// Uses the '/latest' endpoint to get the most recent news articles.
  /// Results are cached for 1 hour to reduce API calls.
  /// 
  /// Parameters:
  /// - [forceRefresh]: Skip cache and fetch fresh data
  /// - [category]: Optional category filter (business, technology, etc.)
  /// - [country]: Optional country filter (us, in, gb, etc.)
  /// 
  /// Returns a list of [NewsArticleModel] objects
  Future<List<NewsArticleModel>> getLatestNews({
    bool forceRefresh = false,
    String? category,
    String? country,
  }) async {
    // Use mock data in development mode
    if (DevApiConfig.useMockData) {
      return await NewsMockDataSource.getLatestNews();
    }

    final cacheKey = 'latest_${category ?? 'all'}_${country ?? 'all'}';
    
    // Check cache first
    if (!forceRefresh) {
      final cached = _cache.get<List<NewsArticleModel>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final queryParams = <String, String>{
      'apikey': ApiConfig.getNewsApiKey(),
      'language': 'en',
    };
    
    if (category != null) queryParams['category'] = category;
    if (country != null) queryParams['country'] = country;

    final uri = Uri.parse(ApiConfig.getEndpointUrl('latest')).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _makeRequest(uri);
      final articles = _parseNewsResponse(response);
      
      // Cache the results
      _cache.set(cacheKey, articles, duration: ApiConfig.cacheDuration);
      
      return articles;
    } catch (e) {
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      throw NewsException('Failed to fetch latest news', originalError: e);
    }
  }

  /// Fetches cryptocurrency news from NewsData.io
  /// 
  /// Uses the '/latest' endpoint with business category for crypto-specific news.
  /// Results are cached for 1 hour.
  Future<List<NewsArticleModel>> getCryptoNews({
    bool forceRefresh = false,
  }) async {
    // Use mock data in development mode
    if (DevApiConfig.useMockData) {
      return await NewsMockDataSource.getCryptoNews();
    }

    const cacheKey = 'crypto_news';
    
    // Check cache first
    if (!forceRefresh) {
      final cached = _cache.get<List<NewsArticleModel>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final queryParams = {
      'apikey': ApiConfig.getNewsApiKey(),
      'language': 'en',
      'category': 'business', // Use business category for financial/crypto news
      'q': 'cryptocurrency OR bitcoin OR ethereum OR crypto OR blockchain', // Search for crypto terms
    };

    final uri = Uri.parse(ApiConfig.getEndpointUrl('crypto')).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _makeRequest(uri);
      final articles = _parseNewsResponse(response);
      
      // Cache the results
      _cache.set(cacheKey, articles, duration: ApiConfig.cacheDuration);
      
      return articles;
    } catch (e) {
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      throw NewsException('Failed to fetch crypto news', originalError: e);
    }
  }

  /// Fetches market/finance news from NewsData.io
  /// 
  /// Uses the '/latest' endpoint with business category for finance and market news.
  /// Results are cached for 1 hour.
  Future<List<NewsArticleModel>> getMarketNews({
    bool forceRefresh = false,
  }) async {
    // Use mock data in development mode
    if (DevApiConfig.useMockData) {
      return await NewsMockDataSource.getMarketNews();
    }

    const cacheKey = 'market_news';
    
    // Check cache first
    if (!forceRefresh) {
      final cached = _cache.get<List<NewsArticleModel>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final queryParams = {
      'apikey': ApiConfig.getNewsApiKey(),
      'language': 'en',
      'category': 'business', // Use business category for market/finance news
      'q': 'market OR finance OR stock OR trading OR investment OR economy', // Search for market terms
    };

    final uri = Uri.parse(ApiConfig.getEndpointUrl('market')).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _makeRequest(uri);
      final articles = _parseNewsResponse(response);
      
      // Cache the results
      _cache.set(cacheKey, articles, duration: ApiConfig.cacheDuration);
      
      return articles;
    } catch (e) {
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      throw NewsException('Failed to fetch market news', originalError: e);
    }
  }

  /// Fetches news sources information from NewsData.io
  /// 
  /// Uses the '/sources' endpoint to get available news sources.
  /// Results are cached for 24 hours as sources don't change frequently.
  Future<List<Map<String, dynamic>>> getNewsSources({
    bool forceRefresh = false,
    String? category,
    String? country,
  }) async {
    // Use mock data in development mode
    if (DevApiConfig.useMockData) {
      return await NewsMockDataSource.getNewsSources();
    }

    final cacheKey = 'sources_${category ?? 'all'}_${country ?? 'all'}';
    
    // Check cache first (longer cache for sources)
    if (!forceRefresh) {
      final cached = _cache.get<List<Map<String, dynamic>>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final queryParams = <String, String>{
      'apikey': ApiConfig.getNewsApiKey(),
    };
    
    if (category != null) queryParams['category'] = category;
    if (country != null) queryParams['country'] = country;

    final uri = Uri.parse(ApiConfig.getEndpointUrl('sources')).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _makeRequest(uri);
      final sources = _parseSourcesResponse(response);
      
      // Cache sources for 24 hours
      _cache.set(cacheKey, sources, duration: const Duration(hours: 24));
      
      return sources;
    } catch (e) {
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      throw NewsException('Failed to fetch news sources', originalError: e);
    }
  }

  /// Searches for news articles based on query
  /// 
  /// Uses the '/latest' endpoint with a search query parameter.
  /// Results are cached for 30 minutes.
  Future<List<NewsArticleModel>> searchNews(
    String query, {
    bool forceRefresh = false,
    String? category,
  }) async {
    // Use mock data in development mode
    if (DevApiConfig.useMockData) {
      return await NewsMockDataSource.searchNews(query);
    }

    final cacheKey = 'search_${query.hashCode}_${category ?? 'all'}';
    
    // Check cache first (shorter cache for search results)
    if (!forceRefresh) {
      final cached = _cache.get<List<NewsArticleModel>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final queryParams = <String, String>{
      'apikey': ApiConfig.getNewsApiKey(),
      'q': query,
      'language': 'en',
    };
    
    if (category != null) queryParams['category'] = category;

    final uri = Uri.parse(ApiConfig.getEndpointUrl('latest')).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _makeRequest(uri);
      final articles = _parseNewsResponse(response);
      
      // Cache search results for 30 minutes
      _cache.set(cacheKey, articles, duration: const Duration(minutes: 30));
      
      return articles;
    } catch (e) {
      if (e is NewsException || e is NetworkException) {
        rethrow;
      }
      throw NewsException('Failed to search news', originalError: e);
    }
  }

  /// Makes an HTTP request with proper error handling
  /// 
  /// Handles timeouts, network errors, and HTTP status codes.
  /// Returns the parsed JSON response.
  Future<Map<String, dynamic>> _makeRequest(Uri uri) async {
    try {
      final response = await httpClient
          .get(
            uri,
            headers: {
              'User-Agent': 'Smart Expense Tracker/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw NewsException('Invalid response format: ${e.message}');
    } catch (e) {
      throw NetworkException('Network request failed: $e');
    }
  }

  /// Handles HTTP response and parses JSON
  /// 
  /// Validates status codes and parses response body.
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw const NewsException('Failed to parse response JSON');
        }
      
      case 400:
        throw const NewsException(
          'Bad request - check your parameters',
          code: 'bad_request',
        );
      
      case 401:
        throw const NewsException(
          'Unauthorized - check your API key',
          code: 'unauthorized',
        );
      
      case 429:
        throw const NewsException(
          'Rate limit exceeded - please try again later',
          code: 'rate_limited',
        );
      
      case 500:
        throw const NewsException(
          'Server error - please try again later',
          code: 'server_error',
        );
      
      default:
        throw NetworkException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
    }
  }

  /// Parses NewsData.io news response
  List<NewsArticleModel> _parseNewsResponse(Map<String, dynamic> response) {
    final status = response['status'] as String?;
    
    if (status != 'success') {
      final message = response['message'] as String? ?? 'Unknown error';
      throw NewsException('API Error: $message');
    }

    final results = response['results'] as List<dynamic>?;
    if (results == null) {
      return [];
    }

    final articles = <NewsArticleModel>[];
    for (final item in results) {
      try {
        final article = NewsArticleModel.fromNewsDataJson(item as Map<String, dynamic>);
        articles.add(article);
      } catch (e) {
        // Skip invalid articles but continue processing
        continue;
      }
    }

    return articles;
  }

  /// Parses NewsData.io sources response
  List<Map<String, dynamic>> _parseSourcesResponse(Map<String, dynamic> response) {
    final status = response['status'] as String?;
    
    if (status != 'success') {
      final message = response['message'] as String? ?? 'Unknown error';
      throw NewsException('API Error: $message');
    }

    final results = response['results'] as List<dynamic>?;
    if (results == null) {
      return [];
    }

    return results.cast<Map<String, dynamic>>();
  }
}