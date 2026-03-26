#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not installed"
        exit 1
    fi
    print_info "Flutter version: $(flutter --version | head -n 1)"
}

setup_env() {
    print_info "Setting up environment..."

    if [ ! -f .env ]; then
        print_warning ".env not found, creating..."
        cat > .env << EOF
NEWS_API_KEY=your_news_api_key_here
FIREBASE_API_KEY=your_firebase_api_key_here
EOF
    fi

    flutter pub get
    flutter packages pub run build_runner build --delete-conflicting-outputs

    print_success "Environment ready"
}

run_analysis() {
    print_info "Running analysis..."
    flutter analyze
    print_success "Analysis done"
}

check_format() {
    print_info "Checking format..."
    dart format --set-exit-if-changed .
    print_success "Format OK"
}

build_debug() {
    print_info "Building debug APK..."
    setup_env
    flutter build apk --debug
    print_success "Debug APK ready"
}

build_release() {
    print_info "Building release APK..."
    setup_env
    run_analysis
    flutter build apk --release
    print_success "Release APK ready"
}

build_bundle() {
    print_info "Building Play Store AAB..."
    setup_env
    run_analysis
    flutter build appbundle --release
    print_success "AAB ready"
}

clean_build() {
    print_info "Cleaning..."
    flutter clean
    rm -rf .dart_tool/build
    print_success "Clean done"
}

run_ci() {
    print_info "Running CI..."
    setup_env
    check_format
    run_analysis
    build_debug
    print_success "CI complete"
}

case "${1:-help}" in
    "debug") check_flutter; build_debug ;;
    "release") check_flutter; build_release ;;
    "bundle") check_flutter; build_bundle ;;
    "analyze") check_flutter; setup_env; run_analysis ;;
    "format") check_flutter; check_format ;;
    "clean") clean_build ;;
    "ci") check_flutter; run_ci ;;
    "setup") check_flutter; setup_env ;;
    *)
        echo "Usage: $0 [debug|release|bundle|analyze|format|clean|ci|setup]"
        ;;
esac