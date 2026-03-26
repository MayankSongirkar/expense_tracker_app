// News Article Data Model
// 
// Data layer model for news articles that handles JSON serialization/deserialization
// and conversion to/from domain entities. This model is responsible for
// mapping external API responses to internal domain objects.
// 
// Key Responsibilities:
// - JSON serialization and deserialization
// - Data validation and transformation
// - Conversion to domain entities
// - Handling API response variations
// 
// Features:
// - NewsAPI response mapping
// - Null safety and error handling
// - Domain entity conversion
// - JSON factory constructors
// 
// Usage:
// ```dart
// final model = NewsArticleModel.fromJson(jsonData);
// final entity = model.toEntity();
// ```

import '../../domain/entities/news_article.dart';

/// Data model for news articles from NewsAPI
/// 
/// This model handles the JSON structure returned by NewsAPI and provides
/// conversion methods to domain entities.
class NewsArticleModel {
  /// Article title
  final String title;
  
  /// Article description
  final String? description;
  
  /// Article content (may be truncated)
  final String? content;
  
  /// URL to the full article
  final String url;
  
  /// URL to the article image
  final String? urlToImage;
  
  /// Publication date as ISO string
  final String publishedAt;
  
  /// Source information
  final NewsSourceModel source;
  
  /// Article author
  final String? author;

  const NewsArticleModel({
    required this.title,
    required this.url,
    required this.publishedAt,
    required this.source,
    this.description,
    this.content,
    this.urlToImage,
    this.author,
  });

  /// Creates a NewsArticleModel from NewsData.io JSON data
  /// 
  /// Handles the JSON structure returned by NewsData.io API with proper
  /// null safety and validation.
  /// 
  /// Example NewsData.io JSON structure:
  /// ```json
  /// {
  ///   "article_id": "024dea830914e2c3ee5cc74ecb183919",
  ///   "title": "Market Update",
  ///   "description": "Latest market trends...",
  ///   "content": "Full article content...",
  ///   "link": "https://example.com/article",
  ///   "image_url": "https://example.com/image.jpg",
  ///   "pubDate": "2026-03-21 02:05:00",
  ///   "source_id": "handelsblatt",
  ///   "source_name": "Handelsblatt",
  ///   "creator": ["John Doe"],
  ///   "keywords": ["keyword1", "keyword2"],
  ///   "language": "english",
  ///   "country": ["united states of america"],
  ///   "category": ["business"]
  /// }
  /// ```
  factory NewsArticleModel.fromNewsDataJson(Map<String, dynamic> json) {
    try {
      // Handle creator array - take first creator if available
      final creators = json['creator'] as List<dynamic>?;
      final author = creators?.isNotEmpty == true 
          ? creators!.first.toString() 
          : null;

      return NewsArticleModel(
        title: _validateString(json['title'], 'title'),
        description: _parseNullableString(json['description']),
        content: _parseNullableString(json['content']),
        url: _validateString(json['link'], 'link'),
        urlToImage: _parseNullableString(json['image_url']),
        publishedAt: _convertNewsDataDate(json['pubDate']),
        source: NewsSourceModel(
          id: json['source_id'] as String?,
          name: json['source_name'] as String? ?? json['source_id'] as String? ?? 'Unknown Source',
        ),
        author: author,
      );
    } catch (e) {
      throw FormatException('Failed to parse NewsArticleModel from NewsData.io JSON: $e');
    }
  }

  /// Creates a NewsArticleModel from JSON data
  /// 
  /// Handles the JSON structure returned by NewsAPI with proper
  /// null safety and validation.
  /// 
  /// Example JSON structure:
  /// ```json
  /// {
  ///   "title": "Market Update",
  ///   "description": "Latest market trends...",
  ///   "content": "Full article content...",
  ///   "url": "https://example.com/article",
  ///   "urlToImage": "https://example.com/image.jpg",
  ///   "publishedAt": "2024-01-15T10:30:00Z",
  ///   "source": {
  ///     "id": "source-id",
  ///     "name": "Source Name"
  ///   },
  ///   "author": "John Doe"
  /// }
  /// ```
  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    try {
      return NewsArticleModel(
        title: _validateString(json['title'], 'title'),
        description: _parseNullableString(json['description']),
        content: _parseNullableString(json['content']),
        url: _validateString(json['url'], 'url'),
        urlToImage: _parseNullableString(json['urlToImage']),
        publishedAt: _validateString(json['publishedAt'], 'publishedAt'),
        source: NewsSourceModel.fromJson(
          json['source'] as Map<String, dynamic>? ?? {},
        ),
        author: _parseNullableString(json['author']),
      );
    } catch (e) {
      throw FormatException('Failed to parse NewsArticleModel from JSON: $e');
    }
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'source': source.toJson(),
      'author': author,
    };
  }

  /// Converts this model to a domain entity
  /// 
  /// Performs necessary transformations and validations to create
  /// a proper domain entity.
  NewsArticle toEntity() {
    try {
      return NewsArticle(
        id: _generateId(),
        title: title.trim(),
        description: description?.trim(),
        content: content?.trim(),
        url: url.trim(),
        imageUrl: _validateImageUrl(urlToImage),
        publishedAt: _parseDateTime(publishedAt),
        source: source.toEntity(),
        author: author?.trim(),
      );
    } catch (e) {
      throw FormatException('Failed to convert NewsArticleModel to entity: $e');
    }
  }

  /// Generates a unique ID for the article based on URL and title
  String _generateId() {
    final combined = '$url-$title';
    return combined.hashCode.abs().toString();
  }

  /// Validates and cleans image URL
  String? _validateImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final cleanUrl = imageUrl.trim();
    
    // Basic URL validation
    try {
      final uri = Uri.parse(cleanUrl);
      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return cleanUrl;
      }
    } catch (e) {
      // Invalid URL, return null
    }

    return null;
  }

  /// Parses ISO date string to DateTime
  DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      throw FormatException('Invalid date format: $dateString');
    }
  }

  /// Converts NewsData.io date format to ISO format
  static String _convertNewsDataDate(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now().toIso8601String();
    }
    
    final dateString = dateValue.toString();
    
    try {
      // NewsData.io format: "2024-01-15 10:30:00"
      // Convert to ISO format: "2024-01-15T10:30:00Z"
      if (dateString.contains(' ') && !dateString.contains('T')) {
        final parts = dateString.split(' ');
        if (parts.length == 2) {
          return '${parts[0]}T${parts[1]}Z';
        }
      }
      
      // If already in ISO format or parseable, return as is
      DateTime.parse(dateString);
      return dateString;
    } catch (e) {
      // If parsing fails, return current time
      return DateTime.now().toIso8601String();
    }
  }

  /// Validates that a required string field is not null or empty
  static String _validateString(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException('Required field $fieldName is null');
    }
    
    if (value is! String) {
      throw FormatException('Field $fieldName must be a string, got ${value.runtimeType}');
    }
    
    if (value.trim().isEmpty) {
      throw FormatException('Required field $fieldName is empty');
    }
    
    return value.trim();
  }

  /// Safely parses a nullable string field
  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  String toString() {
    return 'NewsArticleModel(title: $title, url: $url, source: ${source.name})';
  }
}

/// Data model for news source information
class NewsSourceModel {
  /// Source identifier (may be null for some sources)
  final String? id;
  
  /// Human-readable source name
  final String name;

  const NewsSourceModel({
    this.id,
    required this.name,
  });

  /// Creates a NewsSourceModel from JSON data
  factory NewsSourceModel.fromJson(Map<String, dynamic> json) {
    return NewsSourceModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown Source',
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Converts this model to a domain entity
  NewsSource toEntity() {
    return NewsSource(
      id: id ?? 'unknown',
      name: name,
    );
  }

  @override
  String toString() => 'NewsSourceModel(id: $id, name: $name)';
}

/// Response model for NewsData.io API responses
class NewsDataResponse {
  /// Response status
  final String status;
  
  /// Total number of results
  final int totalResults;
  
  /// List of articles
  final List<NewsArticleModel> results;
  
  /// Next page token (if any)
  final String? nextPage;

  const NewsDataResponse({
    required this.status,
    required this.totalResults,
    required this.results,
    this.nextPage,
  });

  /// Creates a NewsDataResponse from JSON data
  factory NewsDataResponse.fromJson(Map<String, dynamic> json) {
    try {
      final resultsJson = json['results'] as List<dynamic>? ?? [];
      final articles = resultsJson
          .cast<Map<String, dynamic>>()
          .map((articleJson) => NewsArticleModel.fromNewsDataJson(articleJson))
          .toList();

      return NewsDataResponse(
        status: json['status'] as String? ?? 'unknown',
        totalResults: json['totalResults'] as int? ?? articles.length,
        results: articles,
        nextPage: json['nextPage'] as String?,
      );
    } catch (e) {
      throw FormatException('Failed to parse NewsDataResponse from JSON: $e');
    }
  }

  /// Checks if the response indicates success
  bool get isSuccess => status == 'success';

  /// Checks if the response indicates an error
  bool get isError => status == 'error';

  @override
  String toString() {
    return 'NewsDataResponse(status: $status, totalResults: $totalResults, results: ${results.length})';
  }
}

/// Response model for NewsAPI responses
class NewsApiResponse {
  /// Response status
  final String status;
  
  /// Total number of results
  final int totalResults;
  
  /// List of articles
  final List<NewsArticleModel> articles;
  
  /// Error code (if any)
  final String? code;
  
  /// Error message (if any)
  final String? message;

  const NewsApiResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
    this.code,
    this.message,
  });

  /// Creates a NewsApiResponse from JSON data
  factory NewsApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      final articlesJson = json['articles'] as List<dynamic>? ?? [];
      final articles = articlesJson
          .cast<Map<String, dynamic>>()
          .map((articleJson) => NewsArticleModel.fromJson(articleJson))
          .toList();

      return NewsApiResponse(
        status: json['status'] as String? ?? 'unknown',
        totalResults: json['totalResults'] as int? ?? 0,
        articles: articles,
        code: json['code'] as String?,
        message: json['message'] as String?,
      );
    } catch (e) {
      throw FormatException('Failed to parse NewsApiResponse from JSON: $e');
    }
  }

  /// Checks if the response indicates success
  bool get isSuccess => status == 'ok';

  /// Checks if the response indicates an error
  bool get isError => status == 'error';

  @override
  String toString() {
    return 'NewsApiResponse(status: $status, totalResults: $totalResults, articles: ${articles.length})';
  }
}