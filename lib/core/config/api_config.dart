/// API Configuration
/// 
/// Central configuration for all external API services used in the app.
/// This file manages API keys, endpoints, and service configurations.
/// 
/// Security Note:
/// API keys are loaded from .env file for security.
/// Never commit API keys to version control.

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// NewsData.io API Configuration
/// 
/// Get your free API key from: https://newsdata.io/register
/// 
/// Features available:
/// - Latest news from multiple sources
/// - Crypto-specific news
/// - Market/Finance news
/// - News sources information
/// 
/// Endpoints:
/// - Latest: /latest - Latest news articles
/// - Crypto: /crypto - Cryptocurrency news
/// - Sources: /sources - News sources information
/// - Market: /market - Finance and market news
class ApiConfig {
  /// NewsData.io API key loaded from .env file
  static String get newsApiKey {
    final key = dotenv.env['NEWS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'NEWS_API_KEY not found in .env file. '
        'Please add your NewsData.io API key to the .env file. '
        'Get your free key from: https://newsdata.io/register'
      );
    }
    return key;
  }
  
  /// NewsData.io base URL
  static const String newsApiBaseUrl = 'https://newsdata.io/api/1';
  
  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Default page size for news requests
  static const int defaultPageSize = 10;
  
  /// Maximum page size allowed by NewsData.io
  static const int maxPageSize = 50;
  
  /// Cache duration for news articles
  static const Duration cacheDuration = Duration(hours: 1);

  /// Available news endpoints
  static const Map<String, String> endpoints = {
    'latest': '/latest',
    'crypto': '/latest', // NewsData.io doesn't have separate crypto endpoint, use category filter
    'sources': '/sources',
    'market': '/latest', // NewsData.io doesn't have separate market endpoint, use category filter
  };

  /// Validates if the NewsData.io API key is configured
  static bool get isNewsApiConfigured {
    try {
      final key = newsApiKey;
      return key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Gets the configured NewsData.io API key
  /// 
  /// Throws an exception if the key is not configured properly.
  static String getNewsApiKey() {
    return newsApiKey;
  }
  
  /// Gets the full URL for a specific endpoint
  static String getEndpointUrl(String endpoint) {
    if (!endpoints.containsKey(endpoint)) {
      throw ArgumentError('Invalid endpoint: $endpoint');
    }
    return '$newsApiBaseUrl${endpoints[endpoint]}';
  }
}

/// Development configuration for testing
class DevApiConfig {
  /// Whether to use mock data instead of real API calls
  static const bool useMockData = true; // Re-enable mock data due to API timeout issues
  
  /// Mock response delay for testing loading states
  static const Duration mockDelay = Duration(seconds: 1);
}

/// Production configuration
class ProdApiConfig {
  /// Production NewsData.io API key (from environment variables)
  static String get newsApiKey {
    // In production, get from environment variables or secure storage
    const key = String.fromEnvironment('NEWS_API_KEY');
    if (key.isEmpty) {
      throw Exception('Production NEWS_API_KEY not found in environment variables');
    }
    return key;
  }
}