import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Session selector widget with FN/AN toggle
class SessionSelector extends StatelessWidget {
  final String selectedSession;
  final ValueChanged<String> onSessionChanged;

  const SessionSelector({
    super.key,
    required this.selectedSession,
    required this.onSessionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.neutral.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SessionButton(
            label: 'Forenoon',
            value: 'FN',
            isSelected: selectedSession == 'FN',
            onTap: () => onSessionChanged('FN'),
          ),
          const SizedBox(width: 4),
          _SessionButton(
            label: 'Afternoon',
            value: 'AN',
            isSelected: selectedSession == 'AN',
            onTap: () => onSessionChanged('AN'),
          ),
        ],
      ),
    );
  }
}

class _SessionButton extends StatefulWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SessionButton> createState() => _SessionButtonState();
}

class _SessionButtonState extends State<_SessionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.accentCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.accentCyan.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected ? AppTheme.white : AppTheme.neutral,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isSelected
                      ? AppTheme.white.withOpacity(0.9)
                      : AppTheme.neutral.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
