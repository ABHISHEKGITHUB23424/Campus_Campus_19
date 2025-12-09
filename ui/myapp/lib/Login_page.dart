import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart'; // Ensure this points to your HomePage file

void main() {
  runApp(const MyApp());
}

const String backendBase = 'http://127.0.0.1:8000';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Connect',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00ADB5),
          primary: const Color(0xFF00ADB5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: const TextStyle(color: Colors.white60),
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIconColor: const Color(0xFF00ADB5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF00ADB5).withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF00ADB5).withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00ADB5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      home: const RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _otpController = TextEditingController();

  final _emailKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final _regKey = GlobalKey<FormState>();

  String role = 'staff'; // 'staff' or 'student'
  bool _loading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendOtp() async {
    if (!(_emailKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    setState(() => _loading = true);

    final url = Uri.parse('$backendBase/api/$role/send_otp');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (res.statusCode == 200) {
        _showSnack('OTP sent to $email.');
        if (!mounted) return;
        setState(() => _currentStep = 1);
      } else {
        final body = json.decode(res.body);
        _showSnack('Error: ${body['detail'] ?? res.reasonPhrase}');
      }
    } catch (e) {
      _showSnack('Request failed: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (!(_otpKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final otp = int.tryParse(_otpController.text.trim());
    if (otp == null) return _showSnack('Enter a valid numeric OTP');

    setState(() => _loading = true);
    final url = Uri.parse('$backendBase/api/$role/verify_otp');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );
      if (res.statusCode == 200) {
        _showSnack('OTP verified.');
        if (!mounted) return;
        setState(() => _currentStep = 2);
      } else {
        final body = json.decode(res.body);
        _showSnack('Error: ${body['detail'] ?? res.reasonPhrase}');
      }
    } catch (e) {
      _showSnack('Request failed: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _completeRegistration() async {
    if (!(_regKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final dept = _departmentController.text.trim();
    final Map<String, dynamic> body = {
      'email': email,
      'name': name,
      'department': dept,
    };
    if (role == 'student') body['year'] = _yearController.text.trim();

    setState(() => _loading = true);
    final url = Uri.parse('$backendBase/api/$role/register');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (res.statusCode == 200) {
        _showSnack('Registration Successful.');
        if (!mounted) return;
        _showLoginDialog(email);
      } else {
        final b = json.decode(res.body);
        _showSnack('Error: ${b['detail'] ?? res.reasonPhrase}');
      }
    } catch (e) {
      _showSnack('Request failed: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loginUser(String email) async {
    setState(() => _loading = true);
    final url = Uri.parse('$backendBase/api/login');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (res.statusCode == 200) {
        _showSnack('Login Successful.');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        final body = json.decode(res.body);
        _showSnack('Login Failed: ${body['detail'] ?? res.reasonPhrase}');
      }
    } catch (e) {
      _showSnack('Request failed: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showLoginDialog(String email) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ADB5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00ADB5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Registration Complete',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Your account has been created successfully. Would you like to login now?',
            style: TextStyle(color: Colors.white60, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Later',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Use post-frame callback to ensure dialog is fully closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _loginUser(email);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Login Now'),
            ),
          ],
        );
      },
    );
  }

  void _showLoginEmailDialog() {
    final _loginEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ADB5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.login,
                  color: Color(0xFF00ADB5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Login to Account',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your registered email address',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _loginEmailController,
                decoration: InputDecoration(
                  hintText: 'name@citchennai.net',
                  labelText: 'College Email',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF00ADB5)),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF00ADB5).withOpacity(0.3),
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final email = _loginEmailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your email')),
                  );
                  return;
                }
                Navigator.pop(context);
                // Use post-frame callback to ensure dialog is fully closed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _loginUser(email);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _resetAll() {
    if (!mounted) return;
    setState(() {
      _currentStep = 0;
      _emailController.clear();
      _otpController.clear();
      _nameController.clear();
      _departmentController.clear();
      _yearController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00ADB5).withOpacity(0.2),
                                const Color(0xFF00ADB5).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00ADB5).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFF00ADB5),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Campus Connect',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back! Please login to continue',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Role Toggle
                  _buildRoleToggle(),
                  const SizedBox(height: 32),

                  // Progress Indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),

                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStepContent(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressDot(0, 'Email'),
        _buildProgressLine(0),
        _buildProgressDot(1, 'Verify'),
        _buildProgressLine(1),
        _buildProgressDot(2, 'Complete'),
      ],
    );
  }

  Widget _buildProgressDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF00ADB5)
                  : const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? const Color(0xFF00ADB5) : Colors.transparent,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00ADB5).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: const TextStyle(
                        color: Colors.white30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white30,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF00ADB5), const Color(0xFF00ADB5)]
                : [const Color(0xFF2A2A2A), const Color(0xFF2A2A2A)],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading
                ? null
                : () async {
                    if (_currentStep == 0)
                      await _sendOtp();
                    else if (_currentStep == 1)
                      await _verifyOtp();
                    else
                      await _completeRegistration();
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF00ADB5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep == 0
                        ? 'Send Verification Code'
                        : _currentStep == 1
                        ? 'Verify Code'
                        : 'Complete Registration',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (_currentStep > 0) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : _resetAll,
            child: const Text(
              'Start Over',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(color: Colors.white60),
            ),
            TextButton(
              onPressed: _loading ? null : _showLoginEmailDialog,
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFF00ADB5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF00ADB5).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _currentStep == 0
                  ? () => setState(() => role = 'staff')
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: role == 'staff'
                      ? const LinearGradient(
                          colors: [Color(0xFF00ADB5), Color(0xFF00ADB5)],
                        )
                      : null,
                  boxShadow: role == 'staff'
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00ADB5).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_center,
                      color: role == 'staff' ? Colors.white : Colors.white30,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Staff',
                      style: TextStyle(
                        color: role == 'staff' ? Colors.white : Colors.white30,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: _currentStep == 0
                  ? () => setState(() => role = 'student')
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: role == 'student'
                      ? const LinearGradient(
                          colors: [Color(0xFF00ADB5), Color(0xFF00ADB5)],
                        )
                      : null,
                  boxShadow: role == 'student'
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00ADB5).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school,
                      color: role == 'student' ? Colors.white : Colors.white30,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Student',
                      style: TextStyle(
                        color: role == 'student'
                            ? Colors.white
                            : Colors.white30,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return Form(
        key: _emailKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Your Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We\'ll send a verification code to your college email',
              style: TextStyle(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: role == 'staff'
                    ? 'name@citchennai.net'
                    : 'firstname.dept2023@citchennai.net',
                labelText: 'College Email',
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Please enter your email';
                if (!v.trim().endsWith('@citchennai.net'))
                  return 'Please use your college email (@citchennai.net)';
                final localPart = v.trim().split('@')[0];
                if (role == 'staff' && localPart.contains('.'))
                  return 'Staff email format: name@citchennai.net';
                if (role == 'student') {
                  if (!RegExp(
                    r'^[a-zA-Z]+[.][a-zA-Z]+[0-9]{4}$',
                  ).hasMatch(localPart)) {
                    return 'Student email format: firstname.dept2023@citchennai.net';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      );
    }
    if (_currentStep == 1) {
      return Form(
        key: _otpKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${_emailController.text}',
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit code',
                labelText: 'Verification Code',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              maxLength: 6,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Please enter the verification code';
                if (int.tryParse(v.trim()) == null)
                  return 'Please enter a valid code';
                return null;
              },
            ),
          ],
        ),
      );
    }
    return Form(
      key: _regKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in your details to complete registration',
            style: TextStyle(fontSize: 14, color: Colors.white60),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter your name' : null,
          ),
          if (role == 'student') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                hintText: 'e.g., Computer Science',
                labelText: 'Department',
                prefixIcon: Icon(Icons.business),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your department'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                hintText: 'e.g., 2023',
                labelText: 'Batch Year',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your batch year'
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
