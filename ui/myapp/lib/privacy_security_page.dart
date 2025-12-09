import 'package:flutter/material.dart';

/// Privacy & Security Page - Manage security settings and privacy
class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // Security settings stored in local state
  bool _twoFactorAuth = false;
  bool _biometricAuth = true;
  bool _locationPermission = true;
  bool _cameraPermission = true;
  bool _storagePermission = true;

  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Change Password Section
          _buildSectionHeader('Change Password'),
          const SizedBox(height: 16),
          _buildPasswordCard(),

          const SizedBox(height: 32),

          // Security Settings Section
          _buildSectionHeader('Security Settings'),
          const SizedBox(height: 12),
          _buildSecurityToggle(
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            icon: Icons.security_outlined,
            value: _twoFactorAuth,
            onChanged: (value) {
              setState(() {
                _twoFactorAuth = value;
              });
              _showSecurityDialog(
                value ? 'Enabled' : 'Disabled',
                'Two-Factor Authentication has been ${value ? 'enabled' : 'disabled'}',
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSecurityToggle(
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face recognition',
            icon: Icons.fingerprint_outlined,
            value: _biometricAuth,
            onChanged: (value) {
              setState(() {
                _biometricAuth = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // App Permissions Section
          _buildSectionHeader('App Permissions'),
          const SizedBox(height: 12),
          _buildSecurityToggle(
            title: 'Location Access',
            subtitle: 'Allow app to access your location',
            icon: Icons.location_on_outlined,
            value: _locationPermission,
            onChanged: (value) {
              setState(() {
                _locationPermission = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSecurityToggle(
            title: 'Camera Access',
            subtitle: 'Allow app to access your camera',
            icon: Icons.camera_alt_outlined,
            value: _cameraPermission,
            onChanged: (value) {
              setState(() {
                _cameraPermission = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSecurityToggle(
            title: 'Storage Access',
            subtitle: 'Allow app to access your files',
            icon: Icons.storage_outlined,
            value: _storagePermission,
            onChanged: (value) {
              setState(() {
                _storagePermission = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // Danger Zone Section
          _buildSectionHeader('Danger Zone'),
          const SizedBox(height: 12),
          _buildDeleteAccountButton(),

          const SizedBox(height: 24),
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

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Old Password Field
            _buildPasswordField(
              controller: _oldPasswordController,
              label: 'Current Password',
              obscureText: !_showOldPassword,
              onToggleVisibility: () {
                setState(() {
                  _showOldPassword = !_showOldPassword;
                });
              },
            ),
            const SizedBox(height: 16),

            // New Password Field
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: !_showNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _showNewPassword = !_showNewPassword;
                });
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: !_showConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 24),

            // Update Password Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ADB5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00ADB5), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.white54,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  Widget _buildSecurityToggle({
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

  Widget _buildDeleteAccountButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_forever_outlined,
            color: Colors.red,
            size: 24,
          ),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        subtitle: const Text(
          'Permanently delete your account',
          style: TextStyle(fontSize: 13, color: Colors.red),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: _showDeleteAccountDialog,
      ),
    );
  }

  void _changePassword() {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all password fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate password change
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSecurityDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00ADB5))),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}