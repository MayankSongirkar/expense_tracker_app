// News Article Entity
// 
// Domain entity representing a financial news article.
// This is the core business object that contains all the essential
// information about a news article without any external dependencies.
// 
// Features:
// - Immutable data structure
// - Rich article information
// - Source attribution
// - Publication metadata
// - Content preview
// 
// Usage:
// ```dart
// final article = NewsArticle(
//   id: 'unique-id',
//   title: 'Market Update',
//   description: 'Latest market trends...',
//   // ... other properties
// );
// ```

import 'package:equatable/equatable.dart';

/// Represents a financial news article from NewsAPI
/// 
/// This entity contains all the essential information about a news article
/// including metadata, content, and source information.
class NewsArticle extends Equatable {
  /// Unique identifier for the article
  final String id;
  
  /// Article headline/title
  final String title;
  
  /// Brief description or excerpt of the article
  final String? description;
  
  /// Full article content (may be truncated by NewsAPI)
  final String? content;
  
  /// URL to the full article
  final String url;
  
  /// URL to the article's featured image
  final String? imageUrl;
  
  /// Publication date and time
  final DateTime publishedAt;
  
  /// News source information
  final NewsSource source;
  
  /// Article author (if available)
  final String? author;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.url,
    required this.publishedAt,
    required this.source,
    this.description,
    this.content,
    this.imageUrl,
    this.author,
  });

  /// Creates a copy of this article with updated values
  NewsArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    DateTime? publishedAt,
    NewsSource? source,
    String? author,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      author: author ?? this.author,
    );
  }

  /// Returns a formatted time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns true if the article has a valid image URL
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Returns a preview of the content (first 150 characters)
  String get contentPreview {
    final text = description ?? content ?? '';
    if (text.length <= 150) return text;
    return '${text.substring(0, 150)}...';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        url,
        imageUrl,
        publishedAt,
        source,
        author,
      ];

  @override
  String toString() {
    return 'NewsArticle(id: $id, title: $title, source: ${source.name})';
  }
}

/// Represents the source of a news article
class NewsSource extends Equatable {
  /// Source identifier
  final String id;
  
  /// Human-readable source name
  final String name;

  const NewsSource({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];

  @override
  String toString() => 'NewsSource(id: $id, name: $name)';
}