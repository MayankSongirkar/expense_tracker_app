#!/bin/bash

# Build script for Expense Tracker Flutter App
# Usage: ./scripts/build.sh [debug|release|test|clean]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    print_info "Flutter version: $(flutter --version | head -n 1)"
}

# Setup environment
setup_env() {
    print_info "Setting up environment..."
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        print_warning ".env file not found, creating template..."
        cat > .env << EOF
NEWS_API_KEY=your_news_api_key_here
FIREBASE_API_KEY=your_firebase_api_key_here
EOF
        print_warning "Please update .env file with your actual API keys"
    fi
    
    # Get dependencies
    print_info "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code
    print_info "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    print_success "Environment setup complete"
}

# Run tests
run_tests() {
    print_info "Running tests..."
    flutter test --coverage
    print_success "Tests completed"
}

# Run analysis
run_analysis() {
    print_info "Running code analysis..."
    flutter analyze
    print_success "Analysis completed"
}

# Check formatting
check_format() {
    print_info "Checking code formatting..."
    dart format --set-exit-if-changed .
    print_success "Formatting check completed"
}

# Build debug APK
build_debug() {
    print_info "Building debug APK..."
    setup_env
    flutter build apk --debug
    print_success "Debug APK built successfully"
    print_info "APK location: build/app/outputs/flutter-apk/app-debug.apk"
}

# Build release APK
build_release() {
    print_info "Building release APK..."
    setup_env
    run_tests
    run_analysis
    flutter build apk --release
    print_success "Release APK built successfully"
    print_info "APK location: build/app/outputs/flutter-apk/app-release.apk"
}

# Build App Bundle
build_bundle() {
    print_info "Building App Bundle..."
    setup_env
    run_tests
    run_analysis
    flutter build appbundle --release
    print_success "App Bundle built successfully"
    print_info "AAB location: build/app/outputs/bundle/release/app-release.aab"
}

# Clean build
clean_build() {
    print_info "Cleaning build artifacts..."
    flutter clean
    rm -rf .dart_tool/build
    print_success "Clean completed"
}

# Full CI pipeline simulation
run_ci() {
    print_info "Running full CI pipeline..."
    setup_env
    check_format
    run_analysis
    run_tests
    build_debug
    print_success "CI pipeline completed successfully"
}

# Main script logic
case "${1:-help}" in
    "debug")
        check_flutter
        build_debug
        ;;
    "release")
        check_flutter
        build_release
        ;;
    "bundle")
        check_flutter
        build_bundle
        ;;
    "test")
        check_flutter
        setup_env
        run_tests
        ;;
    "analyze")
        check_flutter
        setup_env
        run_analysis
        ;;
    "format")
        check_flutter
        check_format
        ;;
    "clean")
        clean_build
        ;;
    "ci")
        check_flutter
        run_ci
        ;;
    "setup")
        check_flutter
        setup_env
        ;;
    "help"|*)
        echo "Expense Tracker Build Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  debug     Build debug APK"
        echo "  release   Build release APK (with tests and analysis)"
        echo "  bundle    Build App Bundle for Play Store"
        echo "  test      Run tests with coverage"
        echo "  analyze   Run code analysis"
        echo "  format    Check code formatting"
        echo "  clean     Clean build artifacts"
        echo "  ci        Run full CI pipeline locally"
        echo "  setup     Setup environment and dependencies"
        echo "  help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 debug     # Quick debug build"
        echo "  $0 release   # Production build with all checks"
        echo "  $0 ci        # Simulate CI pipeline locally"
        ;;
esac