import 'package:flutter/material.dart';

/// Notification Settings Page - Manage notification preferences
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Notification preferences stored in local state
  bool _appNotifications = true;
  bool _attendanceAlerts = true;
  bool _timetableUpdates = false;
  bool _systemUpdates = true;
  bool _emailNotifications = false;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'Manage your notification preferences',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),

          // General Notifications Section
          _buildSectionHeader('General Notifications'),
          const SizedBox(height: 8),
          _buildNotificationCard(
            title: 'App Notifications',
            subtitle: 'Receive all app notifications',
            icon: Icons.notifications_outlined,
            value: _appNotifications,
            onChanged: (value) {
              setState(() {
                _appNotifications = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on your device',
            icon: Icons.phone_android_outlined,
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            icon: Icons.email_outlined,
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // Activity Notifications Section
          _buildSectionHeader('Activity Notifications'),
          const SizedBox(height: 8),
          _buildNotificationCard(
            title: 'Attendance Alerts',
            subtitle: 'Get notified about attendance updates',
            icon: Icons.event_available_outlined,
            value: _attendanceAlerts,
            onChanged: (value) {
              setState(() {
                _attendanceAlerts = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'Timetable Updates',
            subtitle: 'Get notified about timetable changes',
            icon: Icons.schedule_outlined,
            value: _timetableUpdates,
            onChanged: (value) {
              setState(() {
                _timetableUpdates = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            title: 'System Updates',
            subtitle: 'Get notified about system announcements',
            icon: Icons.update_outlined,
            value: _systemUpdates,
            onChanged: (value) {
              setState(() {
                _systemUpdates = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // Save Preferences Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00ADB5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Your notification preferences are saved automatically',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.white60),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFF00ADB5) : Colors.white30,
            size: 24,
          ),
        ),
        activeColor: const Color(0xFF00ADB5),
        activeTrackColor: const Color(0xFF00ADB5).withOpacity(0.5),
        inactiveThumbColor: Colors.white30,
        inactiveTrackColor: Colors.white10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}