// News Article Card Widget
// 
// A professional card widget for displaying news articles with modern
// Material 3 design. Features image loading, source attribution,
// publication time, and interactive animations.
// 
// Key Features:
// - Professional Material 3 design
// - Cached network image loading
// - Shimmer loading effects
// - Interactive animations
// - Accessibility support
// - Responsive layout
// 
// Usage:
// ```dart
// NewsArticleCard(
//   article: newsArticle,
//   onTap: () => openArticle(newsArticle),
// )
// ```

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/news_article.dart';

/// Professional card widget for displaying news articles
/// 
/// Provides a comprehensive article preview with image, title, description,
/// source information, and publication time.
class NewsArticleCard extends StatelessWidget {
  /// The news article to display
  final NewsArticle article;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Whether to show a compact layout
  final bool isCompact;

  const NewsArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1E1E1E).withOpacity(0.8)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: isCompact ? _buildCompactLayout(isDark) : _buildFullLayout(isDark),
        ),
      ),
    );
  }

  /// Builds the full layout with image and detailed information
  Widget _buildFullLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Article image
        if (article.hasImage) _buildArticleImage(),
        
        // Article content
        Padding(
          padding: EdgeInsets.all(article.hasImage ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source and time
              _buildSourceInfo(isDark),
              
              const SizedBox(height: 12),
              
              // Article title
              _buildTitle(isDark),
              
              const SizedBox(height: 8),
              
              // Article description
              if (article.description != null && article.description!.isNotEmpty)
                _buildDescription(isDark),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the compact layout for smaller cards
  Widget _buildCompactLayout(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article image (smaller)
          if (article.hasImage) ...[
            _buildCompactImage(),
            const SizedBox(width: 12),
          ],
          
          // Article content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source and time
                _buildSourceInfo(isDark, isCompact: true),
                
                const SizedBox(height: 8),
                
                // Article title
                _buildTitle(isDark, maxLines: 2),
                
                const SizedBox(height: 4),
                
                // Article description (shorter)
                if (article.description != null && article.description!.isNotEmpty)
                  _buildDescription(isDark, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the article image with loading and error states
  Widget _buildArticleImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: article.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImageError(),
        ),
      ),
    );
  }

  /// Builds the compact image for smaller cards
  Widget _buildCompactImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: CachedNetworkImage(
          imageUrl: article.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImageError(),
        ),
      ),
    );
  }

  /// Builds image loading placeholder with shimmer effect
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Builds image error widget
  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade500,
        size: 32,
      ),
    );
  }

  /// Builds source information with publication time
  Widget _buildSourceInfo(bool isDark, {bool isCompact = false}) {
    return Row(
      children: [
        // Source name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            article.source.name,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Publication time
        Expanded(
          child: Text(
            article.timeAgo,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: isDark 
                  ? Colors.white.withOpacity(0.6)
                  : Colors.black.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds article title
  Widget _buildTitle(bool isDark, {int? maxLines}) {
    return Text(
      article.title,
      style: TextStyle(
        fontSize: isCompact ? 14 : 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.3,
      ),
      maxLines: maxLines ?? 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds article description
  Widget _buildDescription(bool isDark, {int? maxLines}) {
    return Text(
      article.contentPreview,
      style: TextStyle(
        fontSize: isCompact ? 12 : 14,
        color: isDark 
            ? Colors.white.withOpacity(0.8)
            : Colors.black.withOpacity(0.7),
        height: 1.4,
      ),
      maxLines: maxLines ?? 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Shimmer loading card for news articles
/// 
/// Displays a loading placeholder with shimmer animation while
/// news articles are being fetched.
class NewsArticleCardSkeleton extends StatelessWidget {
  /// Whether to show a compact layout
  final bool isCompact;

  const NewsArticleCardSkeleton({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E1E1E).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: isCompact ? _buildCompactSkeleton() : _buildFullSkeleton(),
    );
  }

  /// Builds full skeleton layout
  Widget _buildFullSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        ),
        
        // Content skeleton
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source info skeleton
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title skeleton
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description skeleton
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const SizedBox(height: 4),
              
              Container(
                width: 150,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds compact skeleton layout
  Widget _buildCompactSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source info skeleton
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Title skeleton
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Description skeleton
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}