# Smart Expense Tracker 💰

A production-ready Flutter application for managing personal expenses with clean architecture, modern UI, comprehensive analytics, and monthly reset functionality. Built specifically for Indian users with INR currency support, PDF receipt generation, and advanced expense tracking capabilities.

## 📱 Features

### Core Functionality
- **Add Expenses**: Create expense entries with title, amount (in ₹), category, date, and optional notes
- **Monthly Reset System**: Automatic monthly archiving with fresh start each month while preserving history
- **Dashboard**: Overview of monthly expenses with category-wise pie chart and recent transactions
- **Expense Management**: View, edit, and delete expenses with comprehensive filtering options
- **Advanced Analytics**: Monthly/yearly expense trends with historical data analysis in Indian Rupees
- **Export Data**: Export expenses to CSV format for external analysis
- **PDF Receipts**: Generate and download professional PDF receipts with Indian numbering system (Lakh/Crore)
- **Historical Data**: Access to all past months and years for comprehensive analysis

### Monthly Reset System 🔄
- **Automatic Archiving**: Monthly expenses are automatically archived when a new month begins
- **Fresh Start**: Each month starts with a clean expense list for better organization
- **Historical Preservation**: All past data is preserved in monthly archives for analytics
- **Yearly Summaries**: Automatic yearly aggregation with trend analysis and insights
- **Manual Control**: Option to manually archive specific months or preview before archiving

### Categories
- 🍔 Food
- ✈️ Travel  
- 🛍️ Shopping
- 📄 Bills
- 📦 Other

### UI/UX Features
- **Material 3 Design System** with professional styling
- **Dark/Light theme support** with seamless switching
- **Responsive layout** for all screen sizes
- **Smooth animations** and micro-interactions
- **Intuitive navigation** with bottom navigation bar
- **Professional onboarding** experience
- **Indian Rupee (₹) formatting** with proper Indian numbering system (Lakh/Crore)
- **Interactive charts** with tooltips and animations
- **Empty states** with helpful guidance for new users
- **Comprehensive documentation** throughout the codebase

## 🏗️ Architecture

This project follows **Clean Architecture** principles with Domain-Driven Design (DDD) and comprehensive documentation:

```
lib/
├── core/                          # Core utilities and configurations
│   ├── di/                       # Dependency injection setup (GetIt)
│   ├── theme/                    # Material 3 theming with dark/light modes
│   └── utils/                    # Utility functions (currency, PDF generation)
├── features/
│   ├── expenses/                 # Expense management feature
│   │   ├── data/                # Data layer
│   │   │   ├── datasources/     # Local data sources (Hive)
│   │   │   │   ├── expense_local_datasource.dart
│   │   │   │   └── expense_archive_datasource.dart
│   │   │   ├── models/          # Data models with Hive adapters
│   │   │   │   ├── expense_model.dart
│   │   │   │   ├── monthly_archive_model.dart
│   │   │   │   └── yearly_summary_model.dart
│   │   │   └── repositories/    # Repository implementations
│   │   ├── domain/              # Business logic layer
│   │   │   ├── entities/        # Domain entities
│   │   │   │   ├── expense.dart
│   │   │   │   ├── monthly_archive.dart
│   │   │   │   └── yearly_summary.dart
│   │   │   ├── repositories/    # Repository interfaces
│   │   │   │   ├── expense_repository.dart
│   │   │   │   └── expense_archive_repository.dart
│   │   │   └── usecases/        # Business use cases
│   │   │       ├── add_expense.dart
│   │   │       ├── get_expenses.dart
│   │   │       ├── archive_current_month.dart
│   │   │       ├── get_monthly_archives.dart
│   │   │       └── generate_expense_receipt.dart
│   │   └── presentation/        # UI layer
│   │       ├── providers/       # Riverpod state management
│   │       ├── screens/         # UI screens
│   │       └── widgets/         # Reusable widgets
│   └── onboarding/              # Onboarding feature
├── ARCHITECTURE.md              # Detailed architecture documentation
└── main.dart                    # App entry point
```

### Key Architecture Benefits
- **Testability**: Each layer can be tested independently
- **Maintainability**: Clear separation makes code easier to maintain  
- **Scalability**: Easy to add new features without affecting existing code
- **Documentation**: Comprehensive inline documentation throughout
- **Type Safety**: Strong typing with proper error handling

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Framework** | Flutter 3.x | Cross-platform mobile development |
| **Language** | Dart | Programming language |
| **State Management** | Riverpod | Reactive state management |
| **Local Database** | Hive | Fast NoSQL database |
| **Charts** | FL Chart | Interactive charts and graphs |
| **PDF Generation** | PDF & Printing | Professional receipt generation |
| **Dependency Injection** | GetIt | Service locator pattern |
| **Architecture** | Clean Architecture + DDD | Maintainable code structure |
| **Currency Formatting** | Intl | Indian Rupee formatting |
| **Documentation** | Comprehensive inline docs | Code maintainability |

### Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # State management with compile-time safety
  hive: ^2.2.3                # Fast, lightweight NoSQL database
  hive_flutter: ^1.1.0        # Hive Flutter integration
  fl_chart: ^0.68.0           # Beautiful, animated charts
  get_it: ^7.7.0              # Dependency injection container
  intl: ^0.19.0               # Internationalization & INR formatting
  uuid: ^4.4.0                # UUID generation for unique IDs
  csv: ^6.0.0                 # CSV export functionality
  pdf: ^3.10.8                # PDF document generation
  printing: ^5.12.0           # PDF sharing and printing
  equatable: ^2.0.5           # Value equality for entities
  path_provider: ^2.1.1       # File system access

dev_dependencies:
  build_runner: ^2.4.7        # Code generation
  hive_generator: ^2.0.1      # Hive type adapter generation
  json_annotation: ^4.8.1     # JSON serialization annotations
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart-expense-tracker.git
   cd smart-expense-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters and build files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### Development Setup

1. **Enable developer options** on your device
2. **Connect device** via USB or use emulator
3. **Verify connection**: `flutter devices`
4. **Run in debug mode**: `flutter run`
5. **Hot reload**: Press `r` in terminal or use IDE shortcuts

## 📊 Screenshots

| Dashboard | Add Expense | Analytics | Expense List |
|-----------|-------------|-----------|--------------|
| ![Dashboard](screenshots/dashboard.png) | ![Add](screenshots/add_expense.png) | ![Analytics](screenshots/analytics.png) | ![List](screenshots/expense_list.png) |

## 🎯 Key Features Breakdown

### Dashboard Screen
- **Monthly Summary**: Current month expense overview with INR formatting
- **Category Visualization**: Interactive pie chart with category breakdown
- **Recent Transactions**: Latest expenses with quick access to details
- **Quick Actions**: Fast access to add new expenses and view analytics
- **Empty States**: Helpful guidance for new users with no data

### Monthly Reset System 🔄
- **Automatic Archiving**: Seamless monthly reset when new month begins
- **Manual Control**: Archive specific months or preview before archiving
- **Data Preservation**: Complete historical data maintained in archives
- **Yearly Aggregation**: Automatic yearly summaries with trend analysis
- **Analytics Integration**: Historical data powers comprehensive analytics

### Expense Management
- **Add/Edit**: Form validation with date picker and category selection (amounts in ₹)
- **List View**: Searchable and filterable expense list with INR formatting
- **Details**: Comprehensive expense details with edit/delete options
- **PDF Receipts**: Generate professional PDF receipts with Indian numbering system
- **Filtering**: By category, date range, and search terms
- **Bulk Operations**: Export and archive multiple expenses

### Advanced Analytics 📊
- **Monthly Trends**: Interactive bar charts showing 12-month spending patterns
- **Category Analysis**: Pie charts with detailed category breakdowns
- **Yearly Summaries**: Annual spending analysis with trend indicators
- **Historical Data**: Access to all archived months and years
- **Statistical Insights**: Averages, totals, and spending consistency scores
- **Export Capabilities**: CSV export for external analysis
- **Empty State Handling**: Professional empty states for new users

### Data Management
- **Local Storage**: Fast Hive database with type-safe adapters
- **Archive System**: Monthly archives with yearly summaries
- **CSV Export**: Comprehensive data export with INR formatting
- **PDF Generation**: Professional receipts with Indian numbering (Lakh/Crore)
- **Data Integrity**: Atomic operations and consistency management
- **Offline-first**: Complete functionality without internet connection

### Professional UI/UX
- **Material 3 Design**: Latest Google design system implementation
- **Theme Management**: Seamless dark/light mode switching
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Micro-interactions**: Smooth animations and transitions
- **Accessibility**: Screen reader support and proper contrast ratios
- **Indian Localization**: Proper INR formatting with Lakh/Crore notation

## 🔧 Configuration

### Theme Customization
Modify `lib/core/theme/app_theme.dart` to customize colors and styling:

```dart
class AppTheme {
  // Update primary colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  
  // Customize gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Adding New Categories
Update the expense categories in your category selection logic:

```dart
static const List<String> expenseCategories = [
  'Food',
  'Travel',
  'Shopping',
  'Bills',
  'Other',
  'Healthcare',     // Add new categories
  'Entertainment',  // as needed
];
```

### Currency Formatting
The app uses Indian Rupee formatting with Lakh/Crore notation. Customize in `lib/core/utils/currency_formatter.dart`:

```dart
class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'hi_IN',  // Indian locale
      symbol: '₹',      // Rupee symbol
    );
    return formatter.format(amount);
  }
}
```

### Monthly Reset Configuration
Configure automatic reset behavior in the archive system:

```dart
// Customize reset timing and behavior
class ArchiveSettings {
  static const bool autoResetEnabled = true;
  static const int resetDay = 1; // First day of month
  static const bool preserveCurrentMonth = true;
}
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Structure
```
test/
├── unit/                    # Unit tests
│   ├── domain/             # Domain layer tests
│   ├── data/               # Data layer tests
│   └── utils/              # Utility tests
├── widget/                 # Widget tests
│   ├── screens/            # Screen widget tests
│   └── widgets/            # Component widget tests
└── integration/            # Integration tests
    └── app_test.dart       # Full app integration tests
```

### Testing Guidelines
- **Unit Tests**: Test business logic and use cases
- **Widget Tests**: Test UI components and interactions
- **Integration Tests**: Test complete user workflows
- **Coverage Target**: Maintain >80% code coverage
- **Mocking**: Use proper mocking for external dependencies

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | API 21+ |
| iOS | ✅ Supported | iOS 12+ |
| Web | 🔄 In Progress | PWA support planned |
| Desktop | 🔄 Planned | Windows, macOS, Linux |

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Follow coding standards** and add comprehensive documentation
4. **Write tests** for new functionality
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request** with detailed description

### Development Guidelines

- **Architecture**: Follow Clean Architecture principles
- **Documentation**: Add comprehensive inline documentation
- **Testing**: Write unit tests for new features (aim for >80% coverage)
- **Code Style**: Use conventional commit messages and proper formatting
- **Linting**: Ensure code passes all linting rules (`flutter analyze`)
- **Performance**: Consider performance implications of changes
- **Accessibility**: Ensure new UI components are accessible

### Code Review Process

1. **Automated Checks**: All PRs must pass CI/CD checks
2. **Code Review**: At least one maintainer review required
3. **Testing**: Manual testing on different devices/platforms
4. **Documentation**: Update README and inline docs as needed
5. **Architecture Review**: Ensure changes align with Clean Architecture

### Contribution Areas

- 🐛 **Bug Fixes**: Fix existing issues
- ✨ **New Features**: Add new functionality
- 📚 **Documentation**: Improve documentation
- 🎨 **UI/UX**: Enhance user interface
- ⚡ **Performance**: Optimize app performance
- 🧪 **Testing**: Add or improve tests
- 🌐 **Localization**: Add support for new languages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Hive for efficient local storage
- FL Chart for beautiful chart widgets
- Material Design team for design guidelines

## 📞 Support & Community

### Getting Help

If you encounter any issues or have questions:

1. **Documentation**: Check the comprehensive inline documentation and `ARCHITECTURE.md`
2. **Issues**: Search existing [Issues](https://github.com/yourusername/smart-expense-tracker/issues) or create a new one
3. **Discussions**: Join [GitHub Discussions](https://github.com/yourusername/smart-expense-tracker/discussions) for questions
4. **Wiki**: Check the [project wiki](https://github.com/yourusername/smart-expense-tracker/wiki) for guides

### Community Guidelines

- **Be Respectful**: Treat all community members with respect
- **Be Helpful**: Help others when you can
- **Be Patient**: Remember that everyone is learning
- **Search First**: Check existing issues/discussions before posting
- **Provide Details**: Include relevant information when reporting issues

### Issue Reporting

When reporting bugs, please include:
- **Device Information**: OS version, device model
- **App Version**: Version number and build
- **Steps to Reproduce**: Clear steps to reproduce the issue
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable, add screenshots
- **Logs**: Include relevant error logs or stack traces

### Feature Requests

For feature requests, please provide:
- **Use Case**: Why is this feature needed?
- **Description**: Detailed description of the feature
- **Mockups**: UI mockups if applicable
- **Priority**: How important is this feature?
- **Alternatives**: Any alternative solutions considered?

---

## 📊 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/yourusername/smart-expense-tracker?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/smart-expense-tracker?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/smart-expense-tracker)
![GitHub license](https://img.shields.io/github/license/yourusername/smart-expense-tracker)
![Flutter version](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart version](https://img.shields.io/badge/Dart-3.x-blue)

**Made with ❤️ using Flutter**

*Star ⭐ this repository if you found it helpful!*

---

## 🏆 Acknowledgments

- **Flutter Team**: For the amazing cross-platform framework
- **Riverpod Team**: For excellent state management solution
- **Hive Team**: For fast and efficient local database
- **FL Chart Team**: For beautiful and interactive chart widgets
- **Material Design Team**: For comprehensive design guidelines
- **Open Source Community**: For inspiration and contributions
- **Indian Developer Community**: For feedback on INR formatting and local requirements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Smart Expense Tracker Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```