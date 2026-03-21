import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/analytics_service.dart';

/// Theme mode provider for dark/light mode
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox('settings');
    state = box.get('isDarkMode', defaultValue: false);
  }

  Future<void> toggleTheme() async {
    state = !state;
    final box = await Hive.openBox('settings');
    await box.put('isDarkMode', state);
    
    // Log analytics event for theme change
    await AnalyticsService.logThemeChanged(state ? 'dark' : 'light');
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);
