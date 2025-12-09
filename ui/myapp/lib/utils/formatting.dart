import 'package:intl/intl.dart';

/// Format date to display format (e.g., "Nov 23, 2025")
String formatDateDisplay(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

/// Format date to API format (YYYY-MM-DD)
String formatDateApi(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

/// Format date with day name (e.g., "Monday, Nov 23")
String formatDateWithDay(DateTime date) {
  return DateFormat('EEEE, MMM dd').format(date);
}

/// Format time (e.g., "09:30 AM")
String formatTime(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}

/// Format date and time (e.g., "Nov 23, 2025 at 09:30 AM")
String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(dateTime);
}

/// Parse API date string (YYYY-MM-DD) to DateTime
DateTime parseApiDate(String dateString) {
  return DateFormat('yyyy-MM-dd').parse(dateString);
}

/// Get month-year string (e.g., "November 2025")
String formatMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy').format(date);
}

/// Get month string for API (YYYY-MM)
String formatMonthApi(DateTime date) {
  return DateFormat('yyyy-MM').format(date);
}

/// Get day of week (e.g., "Monday")
String getDayOfWeek(DateTime date) {
  return DateFormat('EEEE').format(date);
}

/// Get short day of week (e.g., "Mon")
String getShortDayOfWeek(DateTime date) {
  return DateFormat('EEE').format(date);
}

/// Check if date is today
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Check if date is yesterday
bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
}

/// Get relative date string (e.g., "Today", "Yesterday", or formatted date)
String getRelativeDateString(DateTime date) {
  if (isToday(date)) {
    return 'Today';
  } else if (isYesterday(date)) {
    return 'Yesterday';
  } else {
    return formatDateDisplay(date);
  }
}

/// Format session display (FN -> Forenoon, AN -> Afternoon)
String formatSession(String session) {
  switch (session.toUpperCase()) {
    case 'FN':
      return 'Forenoon';
    case 'AN':
      return 'Afternoon';
    default:
      return session;
  }
}

/// Get session abbreviation
String getSessionAbbreviation(String session) {
  if (session.toLowerCase().contains('fore')) {
    return 'FN';
  } else if (session.toLowerCase().contains('after')) {
    return 'AN';
  }
  return session;
}

/// Format percentage with 1 decimal place
String formatPercentage(double percentage) {
  return '${percentage.toStringAsFixed(1)}%';
}

/// Format count (e.g., "25 students")
String formatCount(int count, String singular, [String? plural]) {
  if (count == 1) {
    return '$count $singular';
  }
  return '$count ${plural ?? '${singular}s'}';
}

/// Get attendance status color name
String getAttendanceStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'present':
      return 'success';
    case 'absent':
      return 'error';
    case 'late':
      return 'warning';
    default:
      return 'neutral';
  }
}

/// Format phone number (optional, based on your region)
String formatPhoneNumber(String phone) {
  if (phone.length == 10) {
    return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
  }
  return phone;
}

/// Capitalize first letter
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Get initials from name (e.g., "John Doe" -> "JD")
String getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
}

/// Truncate text with ellipsis
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
