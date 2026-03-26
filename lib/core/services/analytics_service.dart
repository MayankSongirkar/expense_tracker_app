// Firebase Analytics Service
// 
// Provides comprehensive user behavior tracking and analytics for the
// Smart Expense Tracker application. This service wraps Firebase Analytics
// to provide consistent event tracking and user insights across the app.
// 
// Features:
// - User behavior tracking
// - Custom event logging
// - Screen view tracking
// - User property management
// - E-commerce event tracking
// - Performance monitoring
// 
// Usage:
// ```dart
// // Track screen views
// AnalyticsService.logScreenView('dashboard');
// 
// // Track user actions
// AnalyticsService.logExpenseAdded(amount: 1500.0, category: 'Food');
// 
// // Set user properties
// AnalyticsService.setUserProperty('preferred_currency', 'INR');
// ```

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service class for Firebase Analytics integration
/// 
/// Provides methods for tracking user behavior, custom events, and app usage
/// to help understand user engagement and optimize the app experience.
class AnalyticsService {
  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  /// Initialize Analytics service
  /// 
  /// Sets up analytics collection and enables/disables based on debug mode.
  /// In debug mode, analytics collection is typically disabled to avoid
  /// noise during development.
  static Future<void> initialize() async {
    // Enable analytics collection in release mode only
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    
    if (kDebugMode) {
      debugPrint('Analytics: Collection disabled in debug mode');
    } else {
      debugPrint('Analytics: Collection enabled for production');
    }
  }

  /// Log screen view events
  /// 
  /// Track when users navigate to different screens in the app.
  /// This helps understand user flow and popular features.
  /// 
  /// Parameters:
  /// - [screenName]: Name of the screen being viewed
  /// - [screenClass]: Optional class name of the screen
  static Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Screen view - $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log screen view: $e');
      }
    }
  }

  /// Log expense creation events
  /// 
  /// Track when users add new expenses to understand spending patterns.
  /// 
  /// Parameters:
  /// - [amount]: Expense amount
  /// - [category]: Expense category
  /// - [currency]: Currency code (default: INR)
  static Future<void> logExpenseAdded({
    required double amount,
    required String category,
    String currency = 'INR',
  }) async {
    try {
      await _analytics.logEvent(
        name: 'expense_added',
        parameters: {
          'amount': amount,
          'category': category,
          'currency': currency,
          'amount_range': _getAmountRange(amount),
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Expense added - ₹$amount ($category)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log expense added: $e');
      }
    }
  }

  /// Log expense editing events
  /// 
  /// Track when users modify existing expenses.
  /// 
  /// Parameters:
  /// - [originalAmount]: Original expense amount
  /// - [newAmount]: New expense amount
  /// - [category]: Expense category
  static Future<void> logExpenseEdited({
    required double originalAmount,
    required double newAmount,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'expense_edited',
        parameters: {
          'original_amount': originalAmount,
          'new_amount': newAmount,
          'category': category,
          'amount_change': newAmount - originalAmount,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Expense edited - ₹$originalAmount → ₹$newAmount');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log expense edited: $e');
      }
    }
  }

  /// Log expense deletion events
  /// 
  /// Track when users delete expenses.
  /// 
  /// Parameters:
  /// - [amount]: Deleted expense amount
  /// - [category]: Expense category
  static Future<void> logExpenseDeleted({
    required double amount,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'expense_deleted',
        parameters: {
          'amount': amount,
          'category': category,
          'amount_range': _getAmountRange(amount),
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Expense deleted - ₹$amount ($category)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log expense deleted: $e');
      }
    }
  }

  /// Log PDF receipt generation
  /// 
  /// Track when users generate PDF receipts.
  /// 
  /// Parameters:
  /// - [amount]: Expense amount
  /// - [category]: Expense category
  static Future<void> logPDFGenerated({
    required double amount,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'pdf_generated',
        parameters: {
          'amount': amount,
          'category': category,
          'feature': 'receipt_generation',
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: PDF generated - ₹$amount ($category)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log PDF generation: $e');
      }
    }
  }

  /// Log CSV export events
  /// 
  /// Track when users export data to CSV.
  /// 
  /// Parameters:
  /// - [expenseCount]: Number of expenses exported
  /// - [totalAmount]: Total amount of exported expenses
  static Future<void> logCSVExported({
    required int expenseCount,
    required double totalAmount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'csv_exported',
        parameters: {
          'expense_count': expenseCount,
          'total_amount': totalAmount,
          'feature': 'data_export',
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: CSV exported - $expenseCount expenses, ₹$totalAmount');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log CSV export: $e');
      }
    }
  }

  /// Log theme changes
  /// 
  /// Track when users switch between light and dark themes.
  /// 
  /// Parameters:
  /// - [theme]: Theme name ('light' or 'dark')
  static Future<void> logThemeChanged(String theme) async {
    try {
      await _analytics.logEvent(
        name: 'theme_changed',
        parameters: {
          'theme': theme,
          'feature': 'theme_switching',
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Theme changed to $theme');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log theme change: $e');
      }
    }
  }

  /// Log monthly reset events
  /// 
  /// Track when monthly expense reset occurs.
  /// 
  /// Parameters:
  /// - [expenseCount]: Number of expenses archived
  /// - [totalAmount]: Total amount archived
  static Future<void> logMonthlyReset({
    required int expenseCount,
    required double totalAmount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'monthly_reset',
        parameters: {
          'archived_expenses': expenseCount,
          'archived_amount': totalAmount,
          'feature': 'monthly_archive',
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Monthly reset - $expenseCount expenses, ₹$totalAmount');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log monthly reset: $e');
      }
    }
  }

  /// Log app launch events
  /// 
  /// Track app launches and session starts.
  static Future<void> logAppLaunch() async {
    try {
      await _analytics.logAppOpen();
      
      if (kDebugMode) {
        debugPrint('Analytics: App launched');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log app launch: $e');
      }
    }
  }

  /// Log feature usage
  /// 
  /// Track when users interact with specific features.
  /// 
  /// Parameters:
  /// - [featureName]: Name of the feature used
  /// - [action]: Action performed on the feature
  /// - [parameters]: Additional parameters
  static Future<void> logFeatureUsage(
    String featureName,
    String action, {
    Map<String, Object>? parameters,
  }) async {
    try {
      final eventParameters = <String, Object>{
        'feature': featureName,
        'action': action,
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: eventParameters,
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Feature usage - $featureName: $action');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log feature usage: $e');
      }
    }
  }

  /// Set user properties
  /// 
  /// Set persistent user properties for analytics segmentation.
  /// 
  /// Parameters:
  /// - [name]: Property name
  /// - [value]: Property value
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, initialValue: value);
      
      if (kDebugMode) {
        debugPrint('Analytics: User property set - $name: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user property: $e');
      }
    }
  }

  /// Set user ID for analytics
  /// 
  /// Set a unique identifier for the user (use anonymous IDs).
  /// 
  /// Parameters:
  /// - [userId]: Anonymous user identifier
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      
      if (kDebugMode) {
        debugPrint('Analytics: User ID set to $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user ID: $e');
      }
    }
  }

  /// Log search events
  /// 
  /// Track when users search for expenses.
  /// 
  /// Parameters:
  /// - [searchTerm]: Search query
  /// - [resultCount]: Number of results found
  static Future<void> logSearch({
    required String searchTerm,
    required int resultCount,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        numberOfNights: null,
        numberOfRooms: null,
        numberOfPassengers: null,
        origin: null,
        destination: null,
        startDate: null,
        endDate: null,
        travelClass: null,
      );

      await _analytics.logEvent(
        name: 'expense_search',
        parameters: <String, Object>{
          'search_term': searchTerm,
          'result_count': resultCount,
          'feature': 'expense_search',
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Search - "$searchTerm" ($resultCount results)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log search: $e');
      }
    }
  }

  /// Log onboarding completion
  /// 
  /// Track when users complete the onboarding process.
  static Future<void> logOnboardingCompleted() async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'feature': 'onboarding',
          'completion_status': 'completed',
        },
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Onboarding completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log onboarding completion: $e');
      }
    }
  }

  /// Get amount range for analytics segmentation
  /// 
  /// Categorizes amounts into ranges for better analytics insights.
  /// 
  /// Parameters:
  /// - [amount]: Expense amount
  /// 
  /// Returns: Amount range category
  static String _getAmountRange(double amount) {
    if (amount < 100) return 'under_100';
    if (amount < 500) return '100_to_500';
    if (amount < 1000) return '500_to_1000';
    if (amount < 5000) return '1000_to_5000';
    if (amount < 10000) return '5000_to_10000';
    return 'above_10000';
  }

  /// Log custom events
  /// 
  /// Log any custom event with parameters.
  /// 
  /// Parameters:
  /// - [eventName]: Name of the event
  /// - [parameters]: Event parameters
  static Future<void> logCustomEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      
      if (kDebugMode) {
        debugPrint('Analytics: Custom event - $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log custom event: $e');
      }
    }
  }

  /// Check if analytics collection is enabled
  /// 
  /// Returns true if analytics collection is currently enabled.
  static bool isAnalyticsCollectionEnabled() {
    return !kDebugMode;
  }
}