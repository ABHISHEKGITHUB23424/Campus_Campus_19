import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_theme.dart';
import 'features/management/pages/management_dashboard_page.dart';

/// Management Login Page (frontend only)
class ManagementLoginPage extends StatefulWidget {
  const ManagementLoginPage({super.key});

  @override
  State<ManagementLoginPage> createState() => _ManagementLoginPageState();
}

class _ManagementLoginPageState extends State<ManagementLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _backgroundController;
  bool _isLoading = false;

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

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      print('✅ Login validated, navigating to dashboard...');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        print('📍 Pushing to ManagementDashboardPage...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ManagementDashboardPage(),
          ),
        );
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
          'Admin Portal',
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
                          AppTheme.accentPurple.withOpacity(0.2),
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
                                AppTheme.accentPurple.withOpacity(0.8),
                                AppTheme.accentPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPurple.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Admin Access',
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
                        'System control & analytics dashboard',
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
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: AppTheme.primaryDark),
                                decoration: _inputDecoration(
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  accentColor: AppTheme.accentPurple,
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter your email'
                                    : (v.contains('@')
                                          ? null
                                          : 'Enter a valid email'),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(color: AppTheme.primaryDark),
                                decoration: _inputDecoration(
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  accentColor: AppTheme.accentPurple,
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter your password'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Forgot Password (frontend only)',
                                          ),
                                        ),
                                      ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppTheme.accentPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _onLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentPurple,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppTheme
                                        .accentPurple
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
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                'Frontend demo - Any credentials will work',
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
    required Color accentColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.neutralLight),
      prefixIcon: Icon(icon, color: accentColor),
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
        borderSide: BorderSide(color: accentColor, width: 2),
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
