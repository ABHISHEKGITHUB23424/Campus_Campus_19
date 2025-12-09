import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../app_theme.dart';
import 'auth_api.dart';
import 'user_session.dart';

/// OTP Verification Page with 6-digit input
class OTPVerificationPage extends StatefulWidget {
  final String email;
  final String userType;
  final String? department;
  final String? batch;

  const OTPVerificationPage({
    super.key,
    required this.email,
    required this.userType,
    this.department,
    this.batch,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _backgroundController;
  // Note: OTP functionality is not implemented in the current backend
  // The backend uses JWT-based authentication instead
  late AuthApi? _authApi;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // _authApi = AuthApi(Dio(), TokenStorage()); // OTP not implemented
    _authApi = null;
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when all 6 digits are entered
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }

    setState(() => _errorMessage = null);
  }

  void _onDigitBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // OTP functionality not implemented - show error
    setState(() {
      _isVerifying = false;
      _errorMessage =
          'OTP verification is not available. Please use direct login instead.';
    });

    /* Original code commented out - OTP not implemented in backend
    return;

    try {
      final response = await _authApi.verifyOtp(widget.email, otp);

      // Extract token and user profile from backend response
      final token = response['access_token'] as String;
      final user = response['user'] as Map<String, dynamic>;

      // Convert batch_year to string if it's an integer
      if (user['batch_year'] != null && user['batch_year'] is int) {
        user['batch'] = user['batch_year'].toString();
      } else if (user['batch_year'] != null) {
        user['batch'] = user['batch_year'];
      }

      // Save session
      await UserSession.saveSession(token: token, profile: user);

      if (mounted) {
        // Navigate to home
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');

        // Clear all fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
    */
  }

  Future<void> _resendOtp() async {
    setState(
      () => _errorMessage =
          'OTP resend is not available. Please use direct login instead.',
    );

    /* Original code commented out - OTP not implemented in backend
    setState(() => _errorMessage = null);

    try {
      await _authApi.requestOtp(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP resent successfully'),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to resend OTP: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
    */
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
          'Verify OTP',
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
                            Icons.mail_lock_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Enter OTP',
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
                        'We\'ve sent a 6-digit code to',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryDarkMedium,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // OTP Input Card
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
                        child: Column(
                          children: [
                            // 6-digit OTP input
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: isDesktop ? 60 : 45,
                                  height: isDesktop ? 60 : 50,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 24 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryDark,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: AppTheme.infoBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall,
                                        ),
                                        borderSide: BorderSide(
                                          color: AppTheme.borderLight,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall,
                                        ),
                                        borderSide: BorderSide(
                                          color: AppTheme.accent,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) =>
                                        _onDigitChanged(index, value),
                                    onTap: () {
                                      // Clear on tap
                                      _controllers[index].clear();
                                    },
                                  ),
                                );
                              }),
                            ),

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

                            // Verify button
                            SizedBox(
                              height: 54,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isVerifying ? null : _verifyOtp,
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
                                child: _isVerifying
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Resend OTP button
                            TextButton(
                              onPressed: _isVerifying ? null : _resendOtp,
                              child: Text(
                                'Didn\'t receive code? Resend',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User info preview
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppTheme.primaryDarkLight,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Role: ${widget.userType == 'student' ? 'Student' : 'Staff'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryDarkLight,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.department != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Department: ${widget.department!.toUpperCase()}, Batch: ${widget.batch}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryDarkLight,
                                ),
                              ),
                            ],
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
}
