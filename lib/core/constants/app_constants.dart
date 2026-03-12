/// Application-wide constants
class AppConstants {
  // Database
  static const String expenseBoxName = 'expenses';
  static const String settingsBoxName = 'settings';
  
  // Settings Keys
  static const String isDarkModeKey = 'isDarkMode';
  static const String isOnboardingCompletedKey = 'isOnboardingCompleted';
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMMM yyyy';
  
  // Categories
  static const List<String> expenseCategories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Other',
  ];
}
