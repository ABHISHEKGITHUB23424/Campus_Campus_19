import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'core/auth_provider.dart';

/// Student Login Page with JWT authentication
class StudentLoginPage extends ConsumerStatefulWidget {
  const StudentLoginPage({super.key});

  @override
  ConsumerState<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends ConsumerState<StudentLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _backgroundController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _department;
  String? _batch;
  bool _isLoginMode = true; // true for login, false for register
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _extractDepartmentAndBatch(String email) {
    // Format: name.deptYYYY@citchennai.net
    // Examples: shreerahuls.csbs2023@citchennai.net
    final localPart = email.split('@').first;
    if (localPart.contains('.')) {
      final parts = localPart.split('.');
      if (parts.length >= 2) {
        final deptAndBatch = parts[1];

        // Try to extract dept and batch from format like "csbs2023"
        // Look for 4-digit year (20XX or 19XX) at the end
        final match = RegExp(r'^([a-zA-Z]+)(\d{4})$').firstMatch(deptAndBatch);
        if (match != null) {
          setState(() {
            _department = match.group(1)!.toUpperCase();
            _batch = match.group(2)!;
          });
          return;
        }
      }
    }
    setState(() {
      _department = null;
      _batch = null;
    });
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authNotifier = ref.read(authProvider.notifier);

        if (_isLoginMode) {
          await authNotifier.login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await authNotifier.register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        }

        if (mounted) {
          // Navigate to home on success
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryDark),
        title: Text(
          'Student Portal',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppTheme.backgroundGradient,
                      Colors.white,
                    ],
                    stops: [
                      0.0,
                      math.sin(_backgroundController.value * 2 * math.pi) *
                              0.2 +
                          0.5,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating accent blob
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    math.cos(_backgroundController.value * 2 * math.pi) * 30,
                    math.sin(_backgroundController.value * 2 * math.pi) * 30,
                  ),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accent.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 48 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 480 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isDesktop ? 60 : 40),

                      // Icon badge
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.accent.withOpacity(0.8),
                                AppTheme.accent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Student Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _isLoginMode
                            ? 'Enter your credentials to login'
                            : 'Create your student account',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryDarkMedium,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Login form card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, AppTheme.cardBackground],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.borderLight,
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.mediumShadow,
                        ),
                        padding: EdgeInsets.all(isDesktop ? 40 : 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: AppTheme.primaryDark),
                                decoration: _inputDecoration(
                                  label: 'Student Email',
                                  icon: Icons.email_outlined,
                                  hint: 'name.deptYYYY@citchennai.net',
                                ),
                                onChanged: (value) {
                                  _extractDepartmentAndBatch(value);
                                  setState(() => _errorMessage = null);
                                },
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!v.endsWith('@citchennai.net')) {
                                    return 'Email must end with @citchennai.net';
                                  }
                                  if (!v.contains('.')) {
                                    return 'Invalid format. Use: name.deptYYYY@citchennai.net';
                                  }
                                  final localPart = v.split('@').first;
                                  final parts = localPart.split('.');
                                  if (parts.length < 2) {
                                    return 'Invalid format. Use: name.deptYYYY@citchennai.net';
                                  }
                                  final deptPart = parts[1];
                                  final hasYear = RegExp(
                                    r'\d{4}',
                                  ).hasMatch(deptPart);
                                  if (!hasYear) {
                                    return 'Email must include batch year (e.g., csbs2023)';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: AppTheme.primaryDark),
                                decoration:
                                    _inputDecoration(
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                      hint: 'Enter your password',
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.neutralLight,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (v.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  if (!_isLoginMode) {
                                    // Additional validation for registration
                                    if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
                                      return 'Password must contain at least one letter';
                                    }
                                    if (!RegExp(r'[0-9]').hasMatch(v)) {
                                      return 'Password must contain at least one number';
                                    }
                                  }
                                  return null;
                                },
                              ),

                              // Department & Batch preview
                              if (_department != null && _batch != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.infoBackground,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSmall,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.accentBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: AppTheme.accent,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Department: $_department  •  Batch: $_batch',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Error message
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSmall,
                                    ),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Login/Register button
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _onSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppTheme.accent
                                        .withOpacity(0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMedium,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isLoginMode ? 'Login' : 'Register',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Toggle between login and register
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoginMode = !_isLoginMode;
                                      _errorMessage = null;
                                    });
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.primaryDarkLight,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isLoginMode
                                              ? "Don't have an account? "
                                              : "Already have an account? ",
                                        ),
                                        TextSpan(
                                          text: _isLoginMode
                                              ? 'Register'
                                              : 'Login',
                                          style: TextStyle(
                                            color: AppTheme.accent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info note
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.infoBackground,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                          border: Border.all(
                            color: AppTheme.accentBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppTheme.primaryDarkLight,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Format: name.deptYYYY@citchennai.net (e.g., john.csbs2023@citchennai.net)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryDarkLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppTheme.neutralLight),
      hintStyle: TextStyle(
        color: AppTheme.neutralLight.withOpacity(0.6),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppTheme.accent),
      filled: true,
      fillColor: AppTheme.infoBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}