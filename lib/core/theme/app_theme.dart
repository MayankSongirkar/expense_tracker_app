// Application Theme Configuration
// 
// Centralized theme management for the Smart Expense Tracker application.
// Provides consistent design system with Material 3 components and
// professional color schemes for both light and dark modes.
// 
// Key Features:
// - Material 3 design system compliance
// - Consistent color palette across the app
// - Professional gradient definitions
// - Comprehensive component theming
// - Accessibility-friendly color contrasts
// - Dark mode support with appropriate colors
// 
// Design Philosophy:
// - Clean, modern interface with subtle shadows
// - Consistent spacing and border radius (12-16px)
// - Professional color scheme with indigo primary
// - Smooth transitions and animations
// - User-friendly form controls and buttons

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application theme configuration class
/// 
/// Defines the complete design system for the Smart Expense Tracker app.
/// Contains color definitions, gradients, and complete theme configurations
/// for both light and dark modes.
class AppTheme {
  // ==================== COLOR PALETTE ====================
  
  /// Primary brand color - Indigo for trust and professionalism
  static const Color primaryColor = Color(0xFF6366F1);
  
  /// Secondary color - Emerald for success and positive actions
  static const Color secondaryColor = Color(0xFF10B981);
  
  /// Accent color - Amber for highlights and important elements
  static const Color accentColor = Color(0xFFF59E0B);
  
  /// Error color - Red for error states and destructive actions
  static const Color errorColor = Color(0xFFEF4444);
  
  /// Warning color - Orange for warning states and cautions
  static const Color warningColor = Color(0xFFF97316);
  
  /// Success color - Green for success states and confirmations
  static const Color successColor = Color(0xFF22C55E);

  // ==================== GRADIENT DEFINITIONS ====================
  
  /// Primary gradient used for hero sections and important UI elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light mode card gradient for subtle depth and visual interest
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode card gradient for consistent visual hierarchy
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== LIGHT THEME CONFIGURATION ====================
  
  /// Complete light theme configuration
  /// 
  /// Optimized for daytime use with high contrast and clean aesthetics.
  /// Uses Material 3 design principles with custom color overrides.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: const Color(0xFFFAFAFA),
    ),
    
    /// App Bar styling for clean, modern navigation
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1E293B),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    /// Card styling with subtle shadows and rounded corners
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    /// Input field styling for forms and user input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    /// Primary button styling for main actions
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    /// Secondary button styling for alternative actions
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    /// Bottom navigation styling for main app navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    /// Floating action button styling for primary actions
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  // ==================== DARK THEME CONFIGURATION ====================
  
  /// Complete dark theme configuration
  /// 
  /// Optimized for low-light use with reduced eye strain and OLED-friendly
  /// dark colors. Maintains visual hierarchy with appropriate contrasts.
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFF34D399),
      tertiary: const Color(0xFFFBBF24),
      error: const Color(0xFFF87171),
      surface: const Color(0xFF0F172A),
    ),

    /// Dark mode app bar with light text
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF1F5F9),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Color(0xFFF1F5F9),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    /// Dark mode card styling with appropriate shadows
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
    ),

    /// Dark mode input styling with proper contrast
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    /// Dark mode button styling with adjusted colors
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFF818CF8),
        foregroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    /// Dark mode navigation with appropriate colors
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Color(0xFF0F172A),
      selectedItemColor: Color(0xFF818CF8),
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    /// Dark mode floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF818CF8),
      foregroundColor: Color(0xFF0F172A),
      elevation: 4,
      shape: CircleBorder(),
    ),
  );
}