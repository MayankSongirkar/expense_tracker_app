// Firebase Crashlytics Service
// 
// Provides centralized crash reporting and logging functionality for the
// Smart Expense Tracker application. This service wraps Firebase Crashlytics
// to provide consistent error handling and user tracking across the app.
// 
// Features:
// - Automatic crash reporting
// - Custom error logging
// - User identification for better debugging
// - Performance monitoring integration
// - Non-fatal error tracking
// 
// Usage:
// ```dart
// // Log custom errors
// CrashlyticsService.logError('Custom error message', exception, stackTrace);
// 
// // Set user information
// CrashlyticsService.setUserId('user123');
// 
// // Log custom events
// CrashlyticsService.log('User performed action X');
// ```

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service class for Firebase Crashlytics integration
/// 
/// Provides methods for error reporting, user tracking, and custom logging
/// to help monitor app stability and debug issues in production.
class CrashlyticsService {
  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Initialize Crashlytics service
  /// 
  /// Sets up crash reporting and enables/disables collection based on
  /// debug mode. In debug mode, crash reporting is typically disabled
  /// to avoid noise during development.
  static Future<void> initialize() async {
    // Enable crash collection in release mode only
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    
    if (kDebugMode) {
      // In debug mode, log that Crashlytics is disabled
      debugPrint('Crashlytics: Collection disabled in debug mode');
    }
  }

  /// Log a custom error to Crashlytics
  /// 
  /// Use this method to report non-fatal errors that you want to track
  /// but don't necessarily crash the app.
  /// 
  /// Parameters:
  /// - [message]: Descriptive error message
  /// - [exception]: The exception object (optional)
  /// - [stackTrace]: Stack trace for debugging (optional)
  /// - [fatal]: Whether this should be treated as a fatal error
  static Future<void> logError(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception ?? message,
        stackTrace,
        fatal: fatal,
        information: [message],
      );
      
      if (kDebugMode) {
        debugPrint('Crashlytics Error: $message');
        if (exception != null) debugPrint('Exception: $exception');
      }
    } catch (e) {
      // Fail silently to avoid recursive errors
      if (kDebugMode) {
        debugPrint('Failed to log error to Crashlytics: $e');
      }
    }
  }

  /// Log a custom message to Crashlytics
  /// 
  /// Use this for tracking user actions, app state changes, or other
  /// important events that might help debug issues.
  /// 
  /// Parameters:
  /// - [message]: The message to log
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      
      if (kDebugMode) {
        debugPrint('Crashlytics Log: $message');
      }
    } catch (e) {
      // Fail silently
      if (kDebugMode) {
        debugPrint('Failed to log message to Crashlytics: $e');
      }
    }
  }

  /// Set user identifier for crash reports
  /// 
  /// This helps identify which users are experiencing crashes.
  /// Use anonymous IDs to maintain privacy.
  /// 
  /// Parameters:
  /// - [userId]: Anonymous user identifier
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      
      if (kDebugMode) {
        debugPrint('Crashlytics: User ID set to $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user ID in Crashlytics: $e');
      }
    }
  }

  /// Set custom key-value pairs for crash reports
  /// 
  /// Use this to add context about the app state when crashes occur.
  /// 
  /// Parameters:
  /// - [key]: The key name
  /// - [value]: The value (String, int, double, or bool)
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        await _crashlytics.setCustomKey(key, value.toString());
      }
      
      if (kDebugMode) {
        debugPrint('Crashlytics: Custom key set - $key: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set custom key in Crashlytics: $e');
      }
    }
  }

  /// Force a crash for testing purposes
  /// 
  /// Only use this in debug mode for testing Crashlytics integration.
  /// This method will be ignored in release builds.
  static void testCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }

  /// Check if Crashlytics collection is enabled
  /// 
  /// Returns true if crash reporting is currently enabled.
  /// Note: This is determined by the initialization setting.
  static bool isCrashlyticsCollectionEnabled() {
    // Return based on debug mode since we set collection based on this
    return !kDebugMode;
  }

  /// Send any unsent crash reports
  /// 
  /// Manually trigger sending of cached crash reports.
  /// This is usually handled automatically by Firebase.
  static Future<void> sendUnsentReports() async {
    try {
      await _crashlytics.sendUnsentReports();
      
      if (kDebugMode) {
        debugPrint('Crashlytics: Unsent reports sent');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send unsent reports: $e');
      }
    }
  }
}