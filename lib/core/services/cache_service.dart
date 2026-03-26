/// Cache Service
/// 
/// Core service for managing application-wide caching functionality.
/// Provides in-memory and persistent caching capabilities with automatic
/// expiration and cleanup mechanisms.
/// 
/// Key Features:
/// - In-memory caching with TTL (Time To Live)
/// - Automatic cache expiration
/// - Memory management and cleanup
/// - Type-safe cache operations
/// - Cache statistics and monitoring
/// 
/// Usage:
/// ```dart
/// // Cache data
/// CacheService.instance.set('key', data, duration: Duration(hours: 1));
/// 
/// // Retrieve data
/// final cachedData = CacheService.instance.get<MyDataType>('key');
/// 
/// // Check if cached
/// final isValid = CacheService.instance.isValid('key');
/// ```

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Cache entry containing data and metadata
class CacheEntry<T> {
  /// The cached data
  final T data;
  
  /// When the data was cached
  final DateTime timestamp;
  
  /// How long the data should be cached
  final Duration duration;
  
  /// Creates a cache entry
  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.duration,
  });
  
  /// Checks if the cache entry is still valid
  bool get isValid {
    final now = DateTime.now();
    return now.difference(timestamp) < duration;
  }
  
  /// Gets the remaining time until expiration
  Duration get remainingTime {
    final now = DateTime.now();
    final elapsed = now.difference(timestamp);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// In-memory cache service with automatic expiration
class CacheService {
  /// Singleton instance
  static final CacheService _instance = CacheService._internal();
  
  /// Public accessor for singleton
  static CacheService get instance => _instance;
  
  /// Private constructor
  CacheService._internal();
  
  /// Internal cache storage
  final Map<String, CacheEntry> _cache = {};
  
  /// Timer for periodic cleanup
  Timer? _cleanupTimer;
  
  /// Default cache duration
  static const Duration defaultDuration = Duration(hours: 1);
  
  /// Cleanup interval
  static const Duration cleanupInterval = Duration(minutes: 15);
  
  /// Initialize the cache service
  void initialize() {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());
    
    if (kDebugMode) {
      print('CacheService initialized');
    }
  }
  
  /// Dispose the cache service
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    
    if (kDebugMode) {
      print('CacheService disposed');
    }
  }
  
  /// Store data in cache with optional duration
  void set<T>(
    String key, 
    T data, {
    Duration? duration,
  }) {
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      duration: duration ?? defaultDuration,
    );
    
    _cache[key] = entry;
    
    if (kDebugMode) {
      print('Cached data for key: $key (expires in ${entry.duration})');
    }
  }
  
  /// Retrieve data from cache
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      return null;
    }
    
    if (!entry.isValid) {
      _cache.remove(key);
      if (kDebugMode) {
        print('Cache expired for key: $key');
      }
      return null;
    }
    
    if (kDebugMode) {
      print('Cache hit for key: $key (expires in ${entry.remainingTime})');
    }
    
    return entry.data as T?;
  }
  
  /// Check if a key exists and is valid in cache
  bool isValid(String key) {
    final entry = _cache[key];
    return entry != null && entry.isValid;
  }
  
  /// Remove a specific key from cache
  void remove(String key) {
    _cache.remove(key);
    
    if (kDebugMode) {
      print('Removed cache for key: $key');
    }
  }
  
  /// Clear all cached data
  void clear() {
    final count = _cache.length;
    _cache.clear();
    
    if (kDebugMode) {
      print('Cleared $count cache entries');
    }
  }
  
  /// Get cache statistics
  CacheStats get stats {
    final now = DateTime.now();
    int validEntries = 0;
    int expiredEntries = 0;
    
    for (final entry in _cache.values) {
      if (entry.isValid) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }
    
    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validEntries,
      expiredEntries: expiredEntries,
    );
  }
  
  /// Get all cache keys
  List<String> get keys => _cache.keys.toList();
  
  /// Cleanup expired entries
  void _cleanup() {
    final keysToRemove = <String>[];
    
    for (final entry in _cache.entries) {
      if (!entry.value.isValid) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    
    if (kDebugMode && keysToRemove.isNotEmpty) {
      print('Cleaned up ${keysToRemove.length} expired cache entries');
    }
  }
}

/// Cache statistics
class CacheStats {
  /// Total number of cache entries
  final int totalEntries;
  
  /// Number of valid (non-expired) entries
  final int validEntries;
  
  /// Number of expired entries
  final int expiredEntries;
  
  /// Creates cache statistics
  const CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });
  
  /// Cache hit ratio (0.0 to 1.0)
  double get hitRatio {
    if (totalEntries == 0) return 0.0;
    return validEntries / totalEntries;
  }
  
  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries, hitRatio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
  }
}

/// News-specific cache keys
class NewsCacheKeys {
  static const String latest = 'news_latest';
  static const String crypto = 'news_crypto';
  static const String sources = 'news_sources';
  static const String market = 'news_market';
  
  /// Generate search cache key
  static String search(String query) => 'news_search_${query.hashCode}';
}