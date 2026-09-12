import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

enum AuthMethod {
  email,
  google,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMethod _currentMethod = AuthMethod.email;

  // Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _resetEmailController = TextEditingController();

  // State
  bool _isSignUp = false;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.citizen;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.clearError();

    final success = await auth.signInWithGoogle(role: _selectedRole);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.brandBlue,
          content: Text('Welcome, ${auth.user?.displayName ?? "Citizen"}! Signed in with Google.'),
        ),
      );
    } else if (auth.errorMessage != null && mounted) {
      _showErrorSnackBar(auth.errorMessage!);
    }
  }

  void _handleEmailSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showErrorSnackBar('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters.');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.clearError();

    bool success;
    if (_isSignUp) {
      success = await auth.signUpWithEmail(
        email: email,
        password: password,
        displayName: name.isNotEmpty ? name : null,
        role: _selectedRole,
      );
    } else {
      success = await auth.signInWithEmail(
        email: email,
        password: password,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.brandBlue,
          content: Text(_isSignUp ? 'Account created successfully!' : 'Welcome back to VaanilaiAI!'),
        ),
      );
    } else if (auth.errorMessage != null && mounted) {
      _showErrorSnackBar(auth.errorMessage!);
    }
  }

  void _showForgotPasswordDialog() {
    _resetEmailController.text = _emailController.text.trim();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppColors.brandBlue),
            SizedBox(width: 8),
            Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address. We will send a secure password reset link to your inbox.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'user@example.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final resetEmail = _resetEmailController.text.trim();
              if (resetEmail.isEmpty || !resetEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email address')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final sent = await auth.sendPasswordReset(resetEmail);
              if (mounted) {
                if (sent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.brandBlue,
                      content: Text('Password reset email sent to $resetEmail'),
                    ),
                  );
                } else if (auth.errorMessage != null) {
                  _showErrorSnackBar(auth.errorMessage!);
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent.shade700,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
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
            child: const Text(
              'Skip / Guest',
              style: TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand Header Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_sync_rounded, color: AppColors.brandBlue, size: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentMethod == AuthMethod.email
                  ? (_isSignUp ? 'Create VaanilaiAI Account' : 'Sign In to VaanilaiAI')
                  : 'Connect with Google',
              textAlign: TextAlign.center,
              style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Sync saved locations, radar alerts, and agro advisories securely with Firebase & Firestore.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Provider Switcher Pills (Email vs Google)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  _buildTabPill('Email / Password', AuthMethod.email, isDark),
                  _buildTabPill('Google Sign-In', AuthMethod.google, isDark),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Error banner if any
            if (auth.errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                      onPressed: () => auth.clearError(),
                    ),
                  ],
                ),
              ),
            ],

            // Main Auth Form Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _currentMethod == AuthMethod.email
                  ? _buildEmailForm(auth, isDark, borderColor, surfaceColor, textPrimary, textSecondary)
                  : _buildGoogleForm(auth, isDark, borderColor, surfaceColor, textPrimary, textSecondary),
            ),

            const SizedBox(height: 20),

            // Offline / Guest Mode Notice
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
                      'No sign-in required: You can still enjoy full local weather features as a Guest Citizen.',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.brandBlueDark,
                        fontSize: 12,
                      ),
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
        onTap: () {
          setState(() {
            _currentMethod = method;
          });
          Provider.of<AuthProvider>(context, listen: false).clearError();
        },
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

  // --- Email & Password Form ---
  Widget _buildEmailForm(
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
              prefixIcon: const Icon(Icons.person_outline, size: 20),
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
            prefixIcon: const Icon(Icons.mail_outline, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
          ),
        ),

        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            if (!_isSignUp)
              GestureDetector(
                onTap: _showForgotPasswordDialog,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.brandBlue, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
          ),
        ),

        if (_isSignUp) ...[
          const SizedBox(height: 14),
          Text('Primary Profile / Role', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
        ],

        const SizedBox(height: 22),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: auth.isLoading ? null : _handleEmailSubmit,
          child: auth.isLoading
              ? const SpinKitThreeBounce(color: Colors.white, size: 18)
              : Text(
                  _isSignUp ? 'Create Account' : 'Sign In',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
        ),

        const SizedBox(height: 14),

        Center(
          child: GestureDetector(
            onTap: () {
              setState(() => _isSignUp = !_isSignUp);
              auth.clearError();
            },
            child: Text(
              _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Create Account",
              style: const TextStyle(color: AppColors.brandBlue, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // --- Google Sign-In Form ---
  Widget _buildGoogleForm(
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
          'Select your primary meteorology role before authenticating:',
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 10),
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
            minimumSize: const Size(double.infinity, 52),
            side: BorderSide(color: borderColor, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w900, fontSize: 19),
              ),
            ),
          ),
          label: auth.isLoading
              ? const SpinKitThreeBounce(color: AppColors.brandBlue, size: 18)
              : Text(
                  'Continue with Google',
                  style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
          onPressed: auth.isLoading ? null : _handleGoogleSignIn,
        ),
      ],
    );
  }
}
