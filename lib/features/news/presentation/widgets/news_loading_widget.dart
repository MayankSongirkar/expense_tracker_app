// News Loading Widget
// 
// Professional loading state for news content with skeleton animations.
// Provides visual feedback while news articles are being fetched.

import 'package:flutter/material.dart';
import 'news_skeleton_loader.dart';

/// Loading widget for news content
/// 
/// Shows skeleton loading animations that match the structure of news articles
/// to provide a smooth loading experience.
class NewsLoadingWidget extends StatelessWidget {
  /// Type of loading content
  final NewsLoadingType type;

  const NewsLoadingWidget({
    super.key,
    this.type = NewsLoadingType.articles,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case NewsLoadingType.articles:
        return const NewsSkeletonLoader(itemCount: 5);
      case NewsLoadingType.sources:
        return const NewsSourcesSkeletonLoader(itemCount: 8);
      case NewsLoadingType.search:
        return const NewsSearchSkeletonLoader();
    }
  }
}

/// Types of news loading states
enum NewsLoadingType {
  /// Loading news articles
  articles,
  
  /// Loading news sources
  sources,
  
  /// Loading search results
  search,
}