/// News Search Bar Widget
/// 
/// A professional search bar widget for news articles with modern
/// Material 3 design, animations, and comprehensive functionality.
/// 
/// Key Features:
/// - Material 3 design with animations
/// - Search suggestions and validation
/// - Clear functionality with animations
/// - Keyboard handling and focus management
/// - Accessibility support
/// 
/// Usage:
/// ```dart
/// NewsSearchBar(
///   controller: searchController,
///   focusNode: searchFocusNode,
///   onSubmitted: (query) => performSearch(query),
///   onCleared: () => clearSearch(),
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Professional search bar for news articles
/// 
/// Provides a comprehensive search experience with validation,
/// animations, and proper keyboard handling.
class NewsSearchBar extends StatefulWidget {
  /// Text editing controller for the search input
  final TextEditingController controller;
  
  /// Focus node for managing input focus
  final FocusNode focusNode;
  
  /// Callback when search is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// Callback when search is cleared
  final VoidCallback? onCleared;
  
  /// Whether currently in search mode
  final bool isSearching;
  
  /// Placeholder text for the search input
  final String placeholder;

  const NewsSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onSubmitted,
    this.onCleared,
    this.isSearching = false,
    this.placeholder = 'Search financial news...',
  });

  @override
  State<NewsSearchBar> createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar>
    with SingleTickerProviderStateMixin {
  
  /// Animation controller for search bar animations
  late AnimationController _animationController;
  
  /// Scale animation for the search bar
  late Animation<double> _scaleAnimation;
  
  /// Whether the search bar is focused
  bool _isFocused = false;
  
  /// Whether there's text in the search field
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to focus changes
    widget.focusNode.addListener(_onFocusChanged);
    
    // Listen to text changes
    widget.controller.addListener(_onTextChanged);
    
    // Initialize text state
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  /// Handles focus changes
  void _onFocusChanged() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// Handles text changes
  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  /// Handles search submission
  void _onSubmitted(String value) {
    final query = value.trim();
    if (query.isNotEmpty) {
      widget.onSubmitted?.call(query);
      HapticFeedback.lightImpact();
    }
  }

  /// Handles search clear
  void _onCleared() {
    widget.controller.clear();
    widget.onCleared?.call();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFocused 
                      ? AppTheme.primaryColor
                      : isDark 
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused 
                        ? AppTheme.primaryColor.withValues(alpha: 0.2)
                        : isDark 
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                    blurRadius: _isFocused ? 16 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: _isFocused ? 2 : 0,
                  ),
                ],
              ),
              child: _buildSearchField(isDark),
            ),
          );
        },
      ),
    );
  }

  /// Builds the search text field
  Widget _buildSearchField(bool isDark) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onSubmitted: _onSubmitted,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.6),
          fontSize: 16,
        ),
        prefixIcon: _buildPrefixIcon(isDark),
        suffixIcon: _buildSuffixIcon(isDark),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  /// Builds the prefix icon (search icon)
  Widget _buildPrefixIcon(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isFocused 
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.search_rounded,
          color: _isFocused 
              ? AppTheme.primaryColor
              : isDark 
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }

  /// Builds the suffix icon (clear button or search indicator)
  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.isSearching) {
      return const Padding(
        padding: EdgeInsets.only(right: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }
    
    if (_hasText) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          onPressed: _onCleared,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.8),
            ),
          ),
          tooltip: 'Clear search',
        ),
      );
    }
    
    return null;
  }
}

/// Search suggestions widget for news search
/// 
/// Displays popular search terms and recent searches to help users
/// discover relevant financial news topics.
class NewsSearchSuggestions extends StatelessWidget {
  /// Callback when a suggestion is tapped
  final ValueChanged<String>? onSuggestionTapped;
  
  /// List of recent search queries
  final List<String> recentSearches;

  const NewsSearchSuggestions({
    super.key,
    this.onSuggestionTapped,
    this.recentSearches = const [],
  });

  /// Popular finance search terms
  static const List<String> _popularSearches = [
    'Stock market',
    'Cryptocurrency',
    'Bitcoin',
    'Investment',
    'Economy',
    'Banking',
    'Inflation',
    'GDP',
    'Federal Reserve',
    'Market analysis',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches section
          if (recentSearches.isNotEmpty) ...[
            _buildSectionHeader('Recent Searches', isDark),
            const SizedBox(height: 12),
            _buildSuggestionChips(recentSearches, isDark, isRecent: true),
            const SizedBox(height: 20),
          ],
          
          // Popular searches section
          _buildSectionHeader('Popular Topics', isDark),
          const SizedBox(height: 12),
          _buildSuggestionChips(_popularSearches, isDark),
        ],
      ),
    );
  }

  /// Builds section header
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark 
            ? Colors.white.withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: 0.8),
      ),
    );
  }

  /// Builds suggestion chips
  Widget _buildSuggestionChips(
    List<String> suggestions, 
    bool isDark, {
    bool isRecent = false,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSuggestionTapped?.call(suggestion),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isRecent 
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : isDark 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRecent 
                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRecent) ...[
                    Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isRecent 
                          ? AppTheme.primaryColor
                          : isDark 
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}