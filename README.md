# Smart Expense Tracker 💰

A production-ready Flutter application for managing personal expenses with clean architecture, modern UI, and comprehensive analytics.

## 📱 Features

### Core Functionality
- **Add Expenses**: Create expense entries with title, amount, category, date, and optional notes
- **Dashboard**: Overview of monthly expenses with category-wise pie chart and recent transactions
- **Expense Management**: View, edit, and delete expenses with comprehensive filtering options
- **Analytics**: Monthly expense trends and category-wise spending analysis
- **Export Data**: Export expenses to CSV format for external analysis

### Categories
- 🍔 Food
- ✈️ Travel  
- 🛍️ Shopping
- 📄 Bills
- 📦 Other

### UI/UX Features
- Material 3 Design System
- Dark/Light theme support
- Responsive layout for all screen sizes
- Smooth animations and transitions
- Intuitive navigation with bottom navigation bar
- Professional onboarding experience

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                          # Core utilities and configurations
│   ├── constants/                 # App-wide constants
│   ├── di/                       # Dependency injection setup
│   ├── theme/                    # App theming
│   └── utils/                    # Utility functions
├── features/
│   ├── expenses/                 # Expense management feature
│   │   ├── data/                # Data layer
│   │   │   ├── datasources/     # Local data sources
│   │   │   ├── models/          # Data models
│   │   │   └── repositories/    # Repository implementations
│   │   ├── domain/              # Business logic layer
│   │   │   ├── entities/        # Domain entities
│   │   │   ├── repositories/    # Repository interfaces
│   │   │   └── usecases/        # Business use cases
│   │   └── presentation/        # UI layer
│   │       ├── providers/       # State management
│   │       ├── screens/         # UI screens
│   │       └── widgets/         # Reusable widgets
│   └── onboarding/              # Onboarding feature
└── main.dart                    # App entry point
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **State Management** | Riverpod |
| **Local Database** | Hive |
| **Charts** | FL Chart |
| **Dependency Injection** | GetIt |
| **Architecture** | Clean Architecture |

### Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # State management
  hive: ^2.2.3                # Local database
  hive_flutter: ^1.1.0        # Hive Flutter integration
  fl_chart: ^0.68.0           # Charts and graphs
  get_it: ^7.7.0              # Dependency injection
  intl: ^0.19.0               # Internationalization
  uuid: ^4.4.0                # UUID generation
  csv: ^6.0.0                 # CSV export functionality
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Git

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

3. **Generate Hive adapters**
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

**iOS:**
```bash
flutter build ios --release
```

## 📊 Screenshots

| Dashboard | Add Expense | Analytics | Expense List |
|-----------|-------------|-----------|--------------|
| ![Dashboard](screenshots/dashboard.png) | ![Add](screenshots/add_expense.png) | ![Analytics](screenshots/analytics.png) | ![List](screenshots/expense_list.png) |

## 🎯 Key Features Breakdown

### Dashboard Screen
- Monthly expense summary
- Category-wise pie chart visualization
- Recent transactions list
- Quick access to add new expenses

### Expense Management
- **Add/Edit**: Form validation with date picker and category selection
- **List View**: Searchable and filterable expense list
- **Details**: Comprehensive expense details with edit/delete options
- **Filtering**: By category, date range, and search terms

### Analytics
- Monthly expense bar charts
- Category spending distribution
- Trend analysis over time
- Export capabilities for further analysis

### Data Management
- Local storage with Hive database
- CSV export functionality
- Data backup and restore capabilities
- Offline-first approach

## 🔧 Configuration

### Theme Customization
Modify `lib/core/theme/app_theme.dart` to customize colors and styling:

```dart
static ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change primary color
    brightness: Brightness.light,
  ),
);
```

### Adding New Categories
Update `lib/core/constants/app_constants.dart`:

```dart
static const List<String> expenseCategories = [
  'Food',
  'Travel',
  'Shopping',
  'Bills',
  'Other',
  'Your New Category', // Add here
];
```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

For test coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | API 21+ |
| iOS | ✅ Supported | iOS 12+ |
| Web | 🔄 In Progress | PWA support planned |
| Desktop | 🔄 Planned | Windows, macOS, Linux |

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clean Architecture principles
- Write unit tests for new features
- Use conventional commit messages
- Ensure code passes all linting rules
- Update documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Hive for efficient local storage
- FL Chart for beautiful chart widgets
- Material Design team for design guidelines

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/smart-expense-tracker/issues) page
2. Create a new issue with detailed description
3. Join our [Discord community](https://discord.gg/your-server)

## 🗺️ Roadmap

- [ ] Cloud synchronization
- [ ] Multi-currency support
- [ ] Budget planning and alerts
- [ ] Receipt scanning with OCR
- [ ] Expense sharing with family/friends
- [ ] Advanced analytics and insights
- [ ] Web application
- [ ] Desktop applications

---

**Made with ❤️ using Flutter**

*Star ⭐ this repository if you found it helpful!*