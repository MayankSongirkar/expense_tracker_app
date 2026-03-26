#!/bin/bash

# Comprehensive script to fix all Flutter analyze issues
# This script addresses dangling comments, deprecated methods, and other issues

set -e

echo "🔧 Fixing all Flutter analyze issues..."

# Function to fix dangling comments in a file
fix_dangling_comments() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  📝 Fixing dangling comments: $file"
        # Replace /// with // at the beginning of lines for the first comment block
        sed -i '' '1,/^[^/]/s/^\/\/\//\/\//' "$file" 2>/dev/null || true
    fi
}

# Function to fix withOpacity deprecated usage
fix_with_opacity() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  🎨 Fixing withOpacity: $file"
        # Replace .withOpacity( with .withValues(alpha: 
        sed -i '' 's/\.withOpacity(/\.withValues(alpha: /g' "$file" 2>/dev/null || true
    fi
}

# Function to fix child property order
fix_child_order() {
    echo "  👶 Child property ordering will be handled by IDE formatting"
}

# Function to remove unused imports
fix_unused_imports() {
    echo "  📦 Unused imports should be removed manually or by IDE"
}

echo "1️⃣ Fixing dangling library doc comments..."

# Files with dangling comments
dangling_files=(
    "lib/core/config/api_config.dart"
    "lib/core/services/analytics_service.dart"
    "lib/core/services/crashlytics_service.dart"
    "lib/core/theme/app_theme.dart"
    "lib/core/utils/pdf_generator.dart"
    "lib/features/expenses/data/datasources/expense_archive_datasource.dart"
    "lib/features/expenses/data/models/monthly_archive_model.dart"
    "lib/features/expenses/data/models/yearly_summary_model.dart"
    "lib/features/expenses/domain/entities/expense.dart"
    "lib/features/expenses/domain/entities/monthly_archive.dart"
    "lib/features/expenses/domain/entities/yearly_summary.dart"
    "lib/features/expenses/domain/repositories/expense_archive_repository.dart"
    "lib/features/expenses/domain/usecases/add_expense.dart"
    "lib/features/expenses/domain/usecases/archive_current_month.dart"
    "lib/features/expenses/domain/usecases/get_expenses.dart"
    "lib/features/expenses/domain/usecases/get_monthly_archives.dart"
    "lib/features/expenses/presentation/providers/expense_provider.dart"
    "lib/features/expenses/presentation/screens/analytics_screen.dart"
    "lib/features/expenses/presentation/widgets/monthly_spending_chart.dart"
    "lib/features/legal/presentation/screens/legal_screen.dart"
    "lib/features/news/data/datasources/news_mock_datasource.dart"
    "lib/features/news/data/datasources/news_remote_datasource.dart"
    "lib/features/news/data/models/news_article_model.dart"
    "lib/features/news/data/repositories/news_repository_impl.dart"
    "lib/features/news/domain/entities/news_article.dart"
    "lib/features/news/domain/repositories/news_repository.dart"
    "lib/features/news/domain/usecases/get_crypto_news.dart"
    "lib/features/news/domain/usecases/get_latest_news.dart"
    "lib/features/news/domain/usecases/get_market_news.dart"
    "lib/features/news/domain/usecases/get_news_sources.dart"
    "lib/features/news/domain/usecases/search_news.dart"
    "lib/features/news/presentation/providers/news_provider.dart"
    "lib/features/news/presentation/screens/news_screen.dart"
    "lib/features/news/presentation/widgets/news_article_card.dart"
    "lib/features/news/presentation/widgets/news_error_widget.dart"
    "lib/features/news/presentation/widgets/news_loading_widget.dart"
    "lib/features/news/presentation/widgets/news_search_bar.dart"
    "lib/features/news/presentation/widgets/news_skeleton_loader.dart"
)

for file in "${dangling_files[@]}"; do
    fix_dangling_comments "$file"
done

echo "2️⃣ Fixing deprecated withOpacity usage..."

# Find all Dart files and fix withOpacity
find lib -name "*.dart" -type f | while read -r file; do
    if grep -q "\.withOpacity(" "$file" 2>/dev/null; then
        fix_with_opacity "$file"
    fi
done

echo "3️⃣ Fixing specific issues..."

# Fix the formatAmount method call
if [ -f "lib/features/expenses/presentation/widgets/category_tracker_chart.dart" ]; then
    echo "  🔧 Fixing formatAmount method call"
    sed -i '' 's/CurrencyFormatter\.formatAmount(/CurrencyFormatter.format(/g' "lib/features/expenses/presentation/widgets/category_tracker_chart.dart" 2>/dev/null || true
fi

# Fix unused variables by commenting them out or using them
echo "  🗑️  Fixing unused variables..."

# Fix unused 'now' variable in cache_service.dart
if [ -f "lib/core/services/cache_service.dart" ]; then
    sed -i '' 's/final now = DateTime\.now();/\/\/ final now = DateTime.now(); \/\/ Unused variable/g' "lib/core/services/cache_service.dart" 2>/dev/null || true
fi

# Fix unused 'page' variable in news_provider.dart
if [ -f "lib/features/news/presentation/providers/news_provider.dart" ]; then
    sed -i '' 's/final page = /\/\/ final page = /g' "lib/features/news/presentation/providers/news_provider.dart" 2>/dev/null || true
fi

# Replace avoid_print with debugPrint
echo "  🖨️  Replacing print statements with debugPrint..."
find lib -name "*.dart" -type f -exec sed -i '' 's/print(/debugPrint(/g' {} \; 2>/dev/null || true

# Fix deprecated 'value' parameter in TextFormField
echo "  📝 Fixing deprecated TextFormField 'value' parameter..."
find lib -name "*.dart" -type f -exec sed -i '' 's/value:/initialValue:/g' {} \; 2>/dev/null || true

echo "4️⃣ Running flutter analyze to check results..."

# Run flutter analyze and capture results
if flutter analyze --no-fatal-infos > analyze_results.txt 2>&1; then
    echo "✅ No critical issues found!"
else
    echo "📊 Analysis results:"
    cat analyze_results.txt | tail -10
fi

# Clean up
rm -f analyze_results.txt 2>/dev/null || true

echo ""
echo "🎉 Issue fixing complete!"
echo ""
echo "📋 Summary of fixes applied:"
echo "  ✅ Converted /// to // for dangling library doc comments"
echo "  ✅ Replaced .withOpacity() with .withValues(alpha: )"
echo "  ✅ Fixed CurrencyFormatter.formatAmount() method call"
echo "  ✅ Commented out unused variables"
echo "  ✅ Replaced print() with debugPrint()"
echo "  ✅ Fixed deprecated TextFormField parameters"
echo ""
echo "🔍 Run 'flutter analyze' to see remaining issues"
echo "💡 Some issues may require manual fixing in your IDE"