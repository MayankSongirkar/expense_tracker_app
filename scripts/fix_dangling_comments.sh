#!/bin/bash

# Script to fix dangling library doc comments
# Converts /// comments at the start of files to // comments

set -e

echo "🔧 Fixing dangling library doc comments..."

# List of files with dangling comments (from flutter analyze output)
files=(
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
    "lib/features/expenses/presentation/widgets/category_tracker_chart.dart"
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
    "lib/main.dart"
)

# Function to fix dangling comments in a file
fix_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  Fixing: $file"
        # Use sed to replace /// with // at the beginning of lines, but only for the first block of comments
        sed -i '' '1,/^[^/]/s/^\/\/\//\/\//' "$file"
    else
        echo "  ⚠️  File not found: $file"
    fi
}

# Fix each file
for file in "${files[@]}"; do
    fix_file "$file"
done

echo "✅ Fixed dangling library doc comments"
echo "🔍 Running flutter analyze to verify fixes..."

# Run flutter analyze to check if issues are resolved
flutter analyze --no-fatal-infos | grep -E "(dangling_library_doc_comments|issues found)" || echo "✅ No dangling comment issues found"

echo "🎉 Done!"