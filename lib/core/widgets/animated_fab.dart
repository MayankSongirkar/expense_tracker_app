// Animated Floating Action Button
// 
// A professional floating action button with smooth animations, micro-interactions,
// and enhanced visual feedback. Designed for Google Play Store quality standards.
// 
// Features:
// - Smooth scale animations on press
// - Gradient backgrounds with shadows
// - Pulse animation for attention
// - Hero animation support
// - Accessibility compliance
// - Material 3 design principles

import 'package:flutter/material.dart';
import '../animations/app_animations.dart';
import '../theme/app_theme.dart';

/// Enhanced floating action button with professional animations
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final String? heroTag;
  final bool showPulse;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.heroTag,
    this.showPulse = false,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56.0,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25, // 90 degrees
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppTheme.primaryColor;
    final foregroundColor = widget.foregroundColor ?? Colors.white;

    Widget fab = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.size / 2),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: foregroundColor,
                      size: widget.size * 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Add pulse animation if enabled
    if (widget.showPulse) {
      fab = PulseAnimation(
        duration: const Duration(milliseconds: 2000),
        minScale: 1.0,
        maxScale: 1.05,
        child: fab,
      );
    }

    // Wrap with Hero for navigation animations
    if (widget.heroTag != null) {
      fab = Hero(
        tag: widget.heroTag!,
        child: fab,
      );
    }

    // Add tooltip if provided
    if (widget.tooltip != null) {
      fab = Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    return fab;
  }
}

/// Extended FAB with label animation
class AnimatedExtendedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final String? tooltip;
  final String? heroTag;
  final bool isExtended;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AnimatedExtendedFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.heroTag,
    this.isExtended = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AnimatedExtendedFAB> createState() => _AnimatedExtendedFABState();
}

class _AnimatedExtendedFABState extends State<AnimatedExtendedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AnimationConstants.medium,
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 56.0,
      end: 140.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    if (widget.isExtended) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedExtendedFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExtended != oldWidget.isExtended) {
      if (widget.isExtended) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppTheme.primaryColor;
    final foregroundColor = widget.foregroundColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return BounceAnimation(
          onTap: widget.onPressed,
          child: Container(
            width: _widthAnimation.value,
            height: 56.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  backgroundColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: foregroundColor,
                        size: 24,
                      ),
                      if (_controller.value > 0.5) ...[
                        const SizedBox(width: 8),
                        Opacity(
                          opacity: _opacityAnimation.value,
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: foregroundColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Speed dial FAB with multiple actions
class AnimatedSpeedDial extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final IconData icon;
  final IconData? activeIcon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AnimatedSpeedDial({
    super.key,
    required this.actions,
    required this.icon,
    this.activeIcon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AnimatedSpeedDial> createState() => _AnimatedSpeedDialState();
}

class _AnimatedSpeedDialState extends State<AnimatedSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.medium,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
    });
    
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed dial actions
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * 0.1,
                  0.8 + (index * 0.1),
                  curve: Curves.elasticOut,
                ),
              ));

              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: _controller,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label
                        if (action.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              action.label!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        
                        const SizedBox(width: 16),
                        
                        // Action button
                        BounceAnimation(
                          onTap: () {
                            action.onPressed();
                            _toggle();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: action.backgroundColor ?? AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: (action.backgroundColor ?? AppTheme.secondaryColor)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              action.icon,
                              color: action.foregroundColor ?? Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        
        // Main FAB
        AnimatedFAB(
          onPressed: _toggle,
          icon: _isOpen ? (widget.activeIcon ?? Icons.close) : widget.icon,
          tooltip: widget.tooltip,
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
        ),
      ],
    );
  }
}

/// Speed dial action data class
class SpeedDialAction {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });
}