/// Mock News Data Source
/// 
/// Provides mock news data for development and testing purposes.
/// This data source simulates the NewsData.io API response structure
/// to allow development without network dependencies.

import '../models/news_article_model.dart';

/// Mock data source for news articles
class NewsMockDataSource {
  /// Mock latest news articles
  static List<NewsArticleModel> get mockLatestNews => [
    NewsArticleModel(
      title: "Global Markets Show Strong Recovery Amid Economic Optimism",
      description: "Stock markets worldwide are experiencing significant gains as investors show renewed confidence in economic recovery prospects.",
      content: "Financial markets across the globe are witnessing a remarkable turnaround...",
      url: "https://www.reuters.com/markets/",
      urlToImage: "https://via.placeholder.com/400x200/0066CC/FFFFFF?text=Market+News",
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      source: const NewsSourceModel(
        id: "financial-times",
        name: "Financial Times",
      ),
      author: "Sarah Johnson",
    ),
    NewsArticleModel(
      title: "Technology Sector Leads Innovation in Sustainable Solutions",
      description: "Major tech companies are investing heavily in green technology and sustainable business practices.",
      content: "The technology sector is at the forefront of environmental innovation...",
      url: "https://techcrunch.com/",
      urlToImage: "https://via.placeholder.com/400x200/00AA44/FFFFFF?text=Tech+News",
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      source: const NewsSourceModel(
        id: "tech-daily",
        name: "Tech Daily",
      ),
      author: "Michael Chen",
    ),
    NewsArticleModel(
      title: "Central Banks Signal Continued Support for Economic Growth",
      description: "Federal Reserve and other major central banks maintain accommodative monetary policies to support ongoing recovery.",
      content: "Central banking authorities worldwide are maintaining their commitment...",
      url: "https://www.bloomberg.com/",
      urlToImage: "https://via.placeholder.com/400x200/FF6600/FFFFFF?text=Banking+News",
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      source: const NewsSourceModel(
        id: "reuters",
        name: "Reuters",
      ),
      author: "David Williams",
    ),
  ];

  /// Mock cryptocurrency news articles
  static List<NewsArticleModel> get mockCryptoNews => [
    NewsArticleModel(
      title: "Bitcoin Reaches New All-Time High Amid Institutional Adoption",
      description: "Bitcoin surges to unprecedented levels as major corporations and financial institutions increase their cryptocurrency holdings.",
      content: "The world's largest cryptocurrency has achieved a new milestone...",
      url: "https://coindesk.com/",
      urlToImage: "https://via.placeholder.com/400x200/F7931A/FFFFFF?text=Bitcoin+News",
      publishedAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      source: const NewsSourceModel(
        id: "crypto-insider",
        name: "Crypto Insider",
      ),
      author: "Alex Rodriguez",
    ),
    NewsArticleModel(
      title: "Ethereum 2.0 Upgrade Shows Promising Results for Network Efficiency",
      description: "The latest Ethereum network improvements demonstrate significant gains in transaction speed and energy efficiency.",
      content: "Ethereum's transition to proof-of-stake consensus has yielded impressive results...",
      url: "https://ethereum.org/",
      urlToImage: "https://via.placeholder.com/400x200/627EEA/FFFFFF?text=Ethereum+News",
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      source: const NewsSourceModel(
        id: "blockchain-today",
        name: "Blockchain Today",
      ),
      author: "Emma Thompson",
    ),
    NewsArticleModel(
      title: "DeFi Protocols Report Record Trading Volumes",
      description: "Decentralized finance platforms are experiencing unprecedented user activity and trading volumes.",
      content: "The decentralized finance ecosystem continues to expand rapidly...",
      url: "https://defipulse.com/",
      urlToImage: "https://via.placeholder.com/400x200/9C27B0/FFFFFF?text=DeFi+News",
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      source: const NewsSourceModel(
        id: "defi-pulse",
        name: "DeFi Pulse",
      ),
      author: "James Park",
    ),
  ];

  /// Mock market news articles
  static List<NewsArticleModel> get mockMarketNews => [
    NewsArticleModel(
      title: "S&P 500 Hits Record High on Strong Earnings Reports",
      description: "Major stock indices reach new peaks as quarterly earnings exceed analyst expectations across multiple sectors.",
      content: "The S&P 500 index has achieved another milestone...",
      url: "https://www.marketwatch.com/",
      urlToImage: "https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Market+High",
      publishedAt: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      source: const NewsSourceModel(
        id: "market-watch",
        name: "MarketWatch",
      ),
      author: "Lisa Anderson",
    ),
    NewsArticleModel(
      title: "Oil Prices Stabilize After Recent Volatility",
      description: "Crude oil markets show signs of stabilization following weeks of price fluctuations driven by geopolitical concerns.",
      content: "Energy markets are finding equilibrium after a period of uncertainty...",
      url: "https://www.cnbc.com/energy/",
      urlToImage: "https://via.placeholder.com/400x200/795548/FFFFFF?text=Oil+Market",
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      source: const NewsSourceModel(
        id: "energy-news",
        name: "Energy News",
      ),
      author: "Robert Kim",
    ),
    NewsArticleModel(
      title: "Gold Maintains Safe-Haven Appeal Amid Market Uncertainty",
      description: "Precious metals continue to attract investors seeking portfolio diversification and inflation protection.",
      content: "Gold and other precious metals remain attractive investment options...",
      url: "https://www.investing.com/commodities/gold",
      urlToImage: "https://via.placeholder.com/400x200/FFD700/000000?text=Gold+Market",
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      source: const NewsSourceModel(
        id: "precious-metals",
        name: "Precious Metals Weekly",
      ),
      author: "Maria Garcia",
    ),
  ];

  /// Mock news sources
  static List<Map<String, dynamic>> get mockNewsSources => [
    {
      'id': 'financial-times',
      'name': 'Financial Times',
      'description': 'Global financial and business news',
      'url': 'https://www.ft.com',
      'category': 'business',
      'language': 'en',
      'country': 'gb',
    },
    {
      'id': 'reuters',
      'name': 'Reuters',
      'description': 'International news and information',
      'url': 'https://www.reuters.com',
      'category': 'general',
      'language': 'en',
      'country': 'us',
    },
    {
      'id': 'bloomberg',
      'name': 'Bloomberg',
      'description': 'Business and financial news',
      'url': 'https://www.bloomberg.com',
      'category': 'business',
      'language': 'en',
      'country': 'us',
    },
    {
      'id': 'crypto-insider',
      'name': 'Crypto Insider',
      'description': 'Cryptocurrency and blockchain news',
      'url': 'https://cryptoinsider.com',
      'category': 'technology',
      'language': 'en',
      'country': 'us',
    },
    {
      'id': 'market-watch',
      'name': 'MarketWatch',
      'description': 'Stock market and investment news',
      'url': 'https://www.marketwatch.com',
      'category': 'business',
      'language': 'en',
      'country': 'us',
    },
  ];

  /// Simulates network delay for realistic testing
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Gets mock latest news with simulated delay
  static Future<List<NewsArticleModel>> getLatestNews() async {
    await _simulateNetworkDelay();
    return mockLatestNews;
  }

  /// Gets mock crypto news with simulated delay
  static Future<List<NewsArticleModel>> getCryptoNews() async {
    await _simulateNetworkDelay();
    return mockCryptoNews;
  }

  /// Gets mock market news with simulated delay
  static Future<List<NewsArticleModel>> getMarketNews() async {
    await _simulateNetworkDelay();
    return mockMarketNews;
  }

  /// Gets mock news sources with simulated delay
  static Future<List<Map<String, dynamic>>> getNewsSources() async {
    await _simulateNetworkDelay();
    return mockNewsSources;
  }

  /// Searches mock news articles
  static Future<List<NewsArticleModel>> searchNews(String query) async {
    await _simulateNetworkDelay();
    
    final allArticles = [
      ...mockLatestNews,
      ...mockCryptoNews,
      ...mockMarketNews,
    ];
    
    final queryLower = query.toLowerCase();
    return allArticles.where((article) {
      return article.title.toLowerCase().contains(queryLower) ||
             (article.description?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }
}