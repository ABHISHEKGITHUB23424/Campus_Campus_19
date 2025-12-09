import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../data/models/student.dart';

/// Student checkbox tile for attendance marking
class StudentCheckboxTile extends StatefulWidget {
  final Student student;
  final bool isPresent;
  final ValueChanged<bool> onChanged;
  final int index;

  const StudentCheckboxTile({
    super.key,
    required this.student,
    required this.isPresent,
    required this.onChanged,
    this.index = 0,
  });

  @override
  State<StudentCheckboxTile> createState() => _StudentCheckboxTileState();
}

class _StudentCheckboxTileState extends State<StudentCheckboxTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onChanged(!widget.isPresent);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isPresent
                ? AppTheme.accentCyan.withOpacity(0.1)
                : AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isPresent
                  ? AppTheme.accentCyan
                  : AppTheme.neutral.withOpacity(0.2),
              width: widget.isPresent ? 2 : 1,
            ),
            boxShadow: [
              if (_isPressed || widget.isPresent)
                BoxShadow(
                  color: AppTheme.accentCyan.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onChanged(!widget.isPresent),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Roll number circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isPresent
                            ? AppTheme.accentCyan
                            : AppTheme.neutral.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.student.rollNo?.toString() ?? '?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.isPresent
                                ? AppTheme.white
                                : AppTheme.neutral,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Student info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.student.registerNo ?? 'N/A',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.neutral.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.isPresent
                            ? AppTheme.accentCyan
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.isPresent
                              ? AppTheme.accentCyan
                              : AppTheme.neutral.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: widget.isPresent
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppTheme.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
