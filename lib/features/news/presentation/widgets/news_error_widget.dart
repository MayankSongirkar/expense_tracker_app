/// News Error Widget
/// 
/// Professional error handling widget for news screens with retry
/// functionality and user-friendly error messages. Provides clear
/// feedback when news loading fails with actionable recovery options.
/// 
/// Key Features:
/// - User-friendly error messages
/// - Retry functionality with animations
/// - Professional Material 3 design
/// - Different error types handling
/// - Accessibility support
/// 
/// Usage:
/// ```dart
/// if (hasError) {
///   return NewsErrorWidget(
///     error: errorMessage,
///     onRetry: () => retryLoading(),
///   );
/// }
/// ```

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Professional error widget for news loading failures
/// 
/// Displays user-friendly error messages with retry functionality
/// and appropriate visual feedback based on error type.
class NewsErrorWidget extends StatefulWidget {
  /// Error message to display
  final String error;
  
  /// Callback when retry button is pressed
  final VoidCallback? onRetry;
  
  /// Whether to show a compact layout
  final bool isCompact;

  const NewsErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.isCompact = false,
  });

  @override
  State<NewsErrorWidget> createState() => _NewsErrorWidgetState();
}

class _NewsErrorWidgetState extends State<NewsErrorWidget>
    with SingleTickerProviderStateMixin {
  
  /// Animation controller for error animations
  late AnimationController _animationController;
  
  /// Bounce animation for retry button
  late Animation<double> _bounceAnimation;
  
  /// Fade animation for error content
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handles retry button press with animation
  void _onRetryPressed() {
    _animationController.reverse().then((_) {
      widget.onRetry?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isCompact ? _buildCompactError() : _buildFullError();
  }

  /// Builds the full error layout
  Widget _buildFullError() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon with animation
              ScaleTransition(
                scale: _bounceAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getErrorColor().withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getErrorIcon(),
                    size: 64,
                    color: _getErrorColor(),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error title
              Text(
                _getErrorTitle(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Error message
              Text(
                _getErrorMessage(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              _buildActionButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the compact error layout
  Widget _buildCompactError() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getErrorColor().withValues(alpha: 0.3),
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
        child: Row(
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getErrorColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getErrorIcon(),
                size: 24,
                color: _getErrorColor(),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Error content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getErrorTitle(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getErrorMessage(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Retry button
            if (widget.onRetry != null)
              ScaleTransition(
                scale: _bounceAnimation,
                child: IconButton(
                  onPressed: _onRetryPressed,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Retry',
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds action buttons for the full error layout
  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Primary retry button
        if (widget.onRetry != null)
          ScaleTransition(
            scale: _bounceAnimation,
            child: ElevatedButton.icon(
              onPressed: _onRetryPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Secondary help button
        TextButton.icon(
          onPressed: _showHelpDialog,
          icon: Icon(
            Icons.help_outline_rounded,
            size: 18,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.6),
          ),
          label: Text(
            'Need Help?',
            style: TextStyle(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows help dialog with troubleshooting tips
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Troubleshooting Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Check your internet connection'),
            Text('• Try refreshing the page'),
            Text('• Close and reopen the app'),
            Text('• Check if the news service is available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Gets the appropriate error icon based on error type
  IconData _getErrorIcon() {
    final errorLower = widget.error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('internet')) {
      return Icons.wifi_off_rounded;
    } else if (errorLower.contains('timeout')) {
      return Icons.access_time_rounded;
    } else if (errorLower.contains('server')) {
      return Icons.dns_rounded;
    } else if (errorLower.contains('rate limit')) {
      return Icons.speed_rounded;
    } else {
      return Icons.error_outline_rounded;
    }
  }

  /// Gets the appropriate error color based on error type
  Color _getErrorColor() {
    final errorLower = widget.error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('internet')) {
      return Colors.orange;
    } else if (errorLower.contains('rate limit')) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  /// Gets the appropriate error title based on error type
  String _getErrorTitle() {
    final errorLower = widget.error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('internet')) {
      return 'Connection Problem';
    } else if (errorLower.contains('timeout')) {
      return 'Request Timeout';
    } else if (errorLower.contains('server')) {
      return 'Server Error';
    } else if (errorLower.contains('rate limit')) {
      return 'Too Many Requests';
    } else {
      return 'Something Went Wrong';
    }
  }

  /// Gets the appropriate error message based on error type
  String _getErrorMessage() {
    final errorLower = widget.error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('internet')) {
      return 'Please check your internet connection and try again.';
    } else if (errorLower.contains('timeout')) {
      return 'The request took too long to complete. Please try again.';
    } else if (errorLower.contains('server')) {
      return 'The news service is temporarily unavailable. Please try again later.';
    } else if (errorLower.contains('rate limit')) {
      return 'You\'ve made too many requests. Please wait a moment and try again.';
    } else {
      return 'An unexpected error occurred while loading news. Please try again.';
    }
  }
}

/// Simple error banner for inline error display
/// 
/// Displays a compact error message with dismiss functionality
/// for use in lists or other constrained spaces.
class NewsErrorBanner extends StatelessWidget {
  /// Error message to display
  final String error;
  
  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;
  
  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  const NewsErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade600,
            size: 20,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade800,
              ),
            ),
          ),
          
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                color: Colors.red.shade600,
                size: 18,
              ),
              tooltip: 'Dismiss',
            ),
          ],
        ],
      ),
    );
  }
}