import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Animated button with scale and ripple effects
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isOutlined;
  final double borderRadius;
  final IconData? icon;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
    this.isOutlined = false,
    this.borderRadius = AppTheme.radiusMedium,
    this.icon,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.accentCyan;
    final fgColor = widget.foregroundColor ?? AppTheme.white;

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? _handleTapDown
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? _handleTapUp
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? _handleTapCancel
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.isOutlined
              ? OutlinedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: bgColor, width: 2),
                    foregroundColor: bgColor,
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                  child: _buildContent(bgColor),
                )
              : ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                    foregroundColor: fgColor,
                    elevation: 0,
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                  child: _buildContent(fgColor),
                ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
          widget.child,
        ],
      );
    }

    return widget.child;
  }
}
