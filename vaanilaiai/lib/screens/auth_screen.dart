import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

enum AuthMethod {
  otp,
  google,
  password,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMethod _currentMethod = AuthMethod.otp;

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  // OTP State
  bool _otpSent = false;
  int _resendTimerSeconds = 30;
  Timer? _timer;

  // Form State
  bool _isSignUp = false;
  UserRole _selectedRole = UserRole.citizen;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendTimerSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() => _resendTimerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final code = await auth.sendEmailOtp(email);

    if (mounted) {
      setState(() {
        _otpSent = true;
      });
      _startResendCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.brandBlue,
          content: Text('Verification OTP sent to $email (Demo OTP: $code)'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final name = _nameController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit verification code')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyEmailOtp(
      email: email,
      otp: otp,
      role: _selectedRole,
      displayName: name.isNotEmpty ? name : null,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to VaanilaiAI! Account verified.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or expired OTP. Please check and try again.')),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle(role: _selectedRole);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google successfully!')),
      );
    }
  }

  void _handlePasswordSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithEmail(
      email: email,
      password: password,
      displayName: _isSignUp ? name : null,
      role: _selectedRole,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Authentication'),
        actions: [
          TextButton(
            onPressed: () {
              auth.signInAsGuest();
              Navigator.pop(context);
            },
            child: const Text('Skip / Guest', style: TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_sync_rounded, color: AppColors.brandBlue, size: 36),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Sign In to VaanilaiAI',
              textAlign: TextAlign.center,
              style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Sync saved locations, agro advisories, and disaster alerts across all your devices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Method Selector Pills (Email OTP vs Google vs Password)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  _buildTabPill('Email OTP', AuthMethod.otp, isDark),
                  _buildTabPill('Google', AuthMethod.google, isDark),
                  _buildTabPill('Password', AuthMethod.password, isDark),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Content Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentMethod == AuthMethod.otp) _buildOtpFlow(auth, isDark, borderColor, surfaceColor, textPrimary, textSecondary),
                  if (_currentMethod == AuthMethod.google) _buildGoogleFlow(auth, isDark, borderColor, surfaceColor, textPrimary, textSecondary),
                  if (_currentMethod == AuthMethod.password) _buildPasswordFlow(auth, isDark, borderColor, surfaceColor, textPrimary, textSecondary),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Guest Mode notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceHighlight : AppColors.brandBlueContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, color: AppColors.brandBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No sign-in mandatory: You can use VaanilaiAI 100% offline & locally as a Guest Citizen.',
                      style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.brandBlueDark, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String title, AuthMethod method, bool isDark) {
    final isSelected = _currentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. Email OTP Flow ---
  Widget _buildOtpFlow(
    AuthProvider auth,
    bool isDark,
    Color borderColor,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          enabled: !_otpSent,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. farmer@gmail.com',
            hintStyle: TextStyle(color: textSecondary, fontSize: 13),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
          ),
        ),

        if (!_otpSent) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: auth.isLoading
                ? const SpinKitThreeBounce(color: Colors.white, size: 18)
                : const Text('Send Verification OTP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            onPressed: auth.isLoading ? null : _handleSendOtp,
          ),
        ] else ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enter 6-Digit Code', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => setState(() => _otpSent = false),
                child: const Text('Change Email', style: TextStyle(color: AppColors.brandBlue, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••',
              hintStyle: TextStyle(color: textSecondary, fontSize: 20, letterSpacing: 4),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            ),
          ),

          const SizedBox(height: 14),
          Text('Primary Role / Profession', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            dropdownColor: surfaceColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            ),
            items: const [
              DropdownMenuItem(value: UserRole.citizen, child: Text('General Citizen 🌤️')),
              DropdownMenuItem(value: UserRole.farmer, child: Text('Farmer / Agro Specialist 🌾')),
              DropdownMenuItem(value: UserRole.fisherman, child: Text('Fisherman / Coastal Worker ⛵')),
              DropdownMenuItem(value: UserRole.disasterManager, child: Text('Disaster Response Volunteer 🚨')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: auth.isLoading ? null : _handleVerifyOtp,
            child: auth.isLoading
                ? const SpinKitThreeBounce(color: Colors.white, size: 18)
                : const Text('Verify & Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),

          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _resendTimerSeconds > 0 ? null : _handleSendOtp,
              child: Text(
                _resendTimerSeconds > 0 ? 'Resend code in ${_resendTimerSeconds}s' : 'Resend Verification Code',
                style: TextStyle(
                  color: _resendTimerSeconds > 0 ? textSecondary : AppColors.brandBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- 2. Google Sign-In Flow ---
  Widget _buildGoogleFlow(
    AuthProvider auth,
    bool isDark,
    Color borderColor,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your primary role before connecting Google account:',
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<UserRole>(
          initialValue: _selectedRole,
          dropdownColor: surfaceColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
          ),
          items: const [
            DropdownMenuItem(value: UserRole.citizen, child: Text('General Citizen 🌤️')),
            DropdownMenuItem(value: UserRole.farmer, child: Text('Farmer / Agro Specialist 🌾')),
            DropdownMenuItem(value: UserRole.fisherman, child: Text('Fisherman / Coastal Worker ⛵')),
            DropdownMenuItem(value: UserRole.disasterManager, child: Text('Disaster Response Volunteer 🚨')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _selectedRole = val);
          },
        ),

        const SizedBox(height: 24),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: borderColor, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Center(
              child: Text('G', style: TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
          label: auth.isLoading
              ? const SpinKitThreeBounce(color: AppColors.brandBlue, size: 18)
              : Text('Continue with Google', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          onPressed: auth.isLoading ? null : _handleGoogleSignIn,
        ),
      ],
    );
  }

  // --- 3. Password Flow ---
  Widget _buildPasswordFlow(
    AuthProvider auth,
    bool isDark,
    Color borderColor,
    Color surfaceColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isSignUp) ...[
          Text('Full Name', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Ramesh Kumar',
              hintStyle: TextStyle(color: textSecondary, fontSize: 13),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            ),
          ),
          const SizedBox(height: 14),
        ],

        Text('Email Address', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'user@example.com',
            hintStyle: TextStyle(color: textSecondary, fontSize: 13),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
          ),
        ),

        const SizedBox(height: 14),
        Text('Password', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: textSecondary, fontSize: 13),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
          ),
        ),

        if (_isSignUp) ...[
          const SizedBox(height: 14),
          Text('Primary Role / Occupation', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            dropdownColor: surfaceColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            ),
            items: const [
              DropdownMenuItem(value: UserRole.citizen, child: Text('General Citizen 🌤️')),
              DropdownMenuItem(value: UserRole.farmer, child: Text('Farmer / Agro Specialist 🌾')),
              DropdownMenuItem(value: UserRole.fisherman, child: Text('Fisherman / Marine Coastal ⛵')),
              DropdownMenuItem(value: UserRole.disasterManager, child: Text('Disaster Response Volunteer 🚨')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
        ],

        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: auth.isLoading ? null : _handlePasswordSubmit,
          child: auth.isLoading
              ? const SpinKitThreeBounce(color: Colors.white, size: 18)
              : Text(_isSignUp ? 'Create Account' : 'Sign In', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),

        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
              style: const TextStyle(color: AppColors.brandBlue, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
