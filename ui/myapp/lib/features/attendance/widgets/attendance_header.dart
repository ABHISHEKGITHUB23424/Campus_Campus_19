import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatting.dart';
import '../data/models/class_model.dart';

/// Header widget showing class info and date for attendance pages
class AttendanceHeader extends StatelessWidget {
  final ClassModel classInfo;
  final DateTime? date;
  final String? session;

  const AttendanceHeader({
    super.key,
    required this.classInfo,
    this.date,
    this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primaryDark.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class name
          Text(
            classInfo.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),

          // Subject info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: AppTheme.accentCyan.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  classInfo.subjectCode ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentCyan,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  classInfo.subjectName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Date and session info
          if (date != null || session != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppTheme.white, thickness: 0.5, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (date != null) ...[
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatDateWithDay(date!),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white,
                    ),
                  ),
                ],
                if (date != null && session != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    width: 1,
                    height: 16,
                    color: AppTheme.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 16),
                ],
                if (session != null) ...[
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatSession(session!),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
