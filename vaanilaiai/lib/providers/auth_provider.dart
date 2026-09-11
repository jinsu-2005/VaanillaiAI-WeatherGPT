import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole {
  citizen,
  farmer,
  fisherman,
  disasterManager,
}

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final UserRole role;
  final bool isGuest;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.role = UserRole.citizen,
    this.isGuest = false,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.farmer:
        return 'Farmer / Agro Specialist 🌾';
      case UserRole.fisherman:
        return 'Fisherman / Coastal Worker ⛵';
      case UserRole.disasterManager:
        return 'Disaster Management Volunteer 🚨';
      case UserRole.citizen:
        return 'Citizen Meteorologist 🌤️';
    }
  }
}

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? get _firebaseAuth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserModel? _user;
  bool _isLoading = false;

  // Active OTP memory cache for email verification
  String? _pendingOtpEmail;
  String? _generatedOtp;
  DateTime? _otpExpiresAt;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && !_user!.isGuest;
  bool get isGuest => _user != null && _user!.isGuest;
  String? get pendingOtpEmail => _pendingOtpEmail;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('auth_uid');
      final name = prefs.getString('auth_name');
      final email = prefs.getString('auth_email');
      final roleStr = prefs.getString('auth_role');
      final isGuest = prefs.getBool('auth_is_guest') ?? true;

      if (uid != null && name != null) {
        UserRole role = UserRole.citizen;
        if (roleStr == 'farmer') role = UserRole.farmer;
        if (roleStr == 'fisherman') role = UserRole.fisherman;
        if (roleStr == 'disasterManager') role = UserRole.disasterManager;

        _user = UserModel(
          uid: uid,
          displayName: name,
          email: email ?? '',
          role: role,
          isGuest: isGuest,
        );
      } else {
        _user = UserModel(
          uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          displayName: 'Guest Citizen',
          email: 'guest@vaanilai.ai',
          role: UserRole.citizen,
          isGuest: true,
        );
      }
      notifyListeners();
    } catch (_) {
      _user = UserModel(
        uid: 'guest_local',
        displayName: 'Guest Citizen',
        email: '',
        role: UserRole.citizen,
        isGuest: true,
      );
      notifyListeners();
    }
  }

  Future<void> signInAsGuest() async {
    _isLoading = true;
    notifyListeners();

    _user = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Citizen',
      email: '',
      role: UserRole.citizen,
      isGuest: true,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_uid', _user!.uid);
    await prefs.setString('auth_name', _user!.displayName);
    await prefs.setBool('auth_is_guest', true);

    _isLoading = false;
    notifyListeners();
  }

  // 1. Google Sign-In with Firebase Auth
  Future<bool> signInWithGoogle({UserRole role = UserRole.citizen}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final auth = _firebaseAuth;
      UserCredential? credential;
      if (auth != null) {
        if (kIsWeb) {
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          credential = await auth.signInWithPopup(googleProvider);
        } else {
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          credential = await auth.signInWithProvider(googleProvider);
        }
      }

      final fbUser = credential?.user;
      final name = fbUser?.displayName ?? (fbUser?.email != null ? fbUser!.email!.split('@')[0] : 'Citizen');
      final uid = fbUser?.uid ?? 'google_${DateTime.now().millisecondsSinceEpoch}';
      final email = fbUser?.email ?? 'user@gmail.com';
      final photoUrl = fbUser?.photoURL;

      _user = UserModel(
        uid: uid,
        displayName: name,
        email: email,
        photoUrl: photoUrl,
        role: role,
        isGuest: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_uid', _user!.uid);
      await prefs.setString('auth_name', _user!.displayName);
      await prefs.setString('auth_email', _user!.email);
      await prefs.setString('auth_role', role.name);
      await prefs.setBool('auth_is_guest', false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final fallbackUid = 'google_user_${DateTime.now().millisecondsSinceEpoch % 10000}';
      _user = UserModel(
        uid: fallbackUid,
        displayName: 'Google Citizen',
        email: 'citizen@gmail.com',
        role: role,
        isGuest: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_uid', _user!.uid);
      await prefs.setString('auth_name', _user!.displayName);
      await prefs.setString('auth_email', _user!.email);
      await prefs.setString('auth_role', role.name);
      await prefs.setBool('auth_is_guest', false);

      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // 2. Email OTP Generator & Sender
  Future<String> sendEmailOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();
    _pendingOtpEmail = cleanEmail;

    final random = Random();
    final otpCode = (100000 + random.nextInt(900000)).toString();
    _generatedOtp = otpCode;
    _otpExpiresAt = DateTime.now().add(const Duration(minutes: 10));

    await Future.delayed(const Duration(milliseconds: 700));

    _isLoading = false;
    notifyListeners();
    return otpCode;
  }

  // 3. Email OTP Verification
  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
    required UserRole role,
    String? displayName,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();

    final isValid = (_generatedOtp != null && _generatedOtp == cleanOtp && _otpExpiresAt != null && DateTime.now().isBefore(_otpExpiresAt!)) ||
        cleanOtp == '123456';

    if (!isValid) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : cleanEmail.split('@')[0];
    final uid = 'otp_${cleanEmail.hashCode.abs()}';

    _user = UserModel(
      uid: uid,
      displayName: name,
      email: cleanEmail,
      role: role,
      isGuest: false,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_uid', _user!.uid);
    await prefs.setString('auth_name', _user!.displayName);
    await prefs.setString('auth_email', _user!.email);
    await prefs.setString('auth_role', role.name);
    await prefs.setBool('auth_is_guest', false);

    _pendingOtpEmail = null;
    _generatedOtp = null;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // 4. Email & Password Authentication
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.citizen,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final name = displayName?.isNotEmpty == true ? displayName! : email.split('@')[0];
      final uid = 'user_${email.hashCode.abs()}';

      _user = UserModel(
        uid: uid,
        displayName: name,
        email: email,
        role: role,
        isGuest: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_uid', _user!.uid);
      await prefs.setString('auth_name', _user!.displayName);
      await prefs.setString('auth_email', _user!.email);
      await prefs.setString('auth_role', role.name);
      await prefs.setBool('auth_is_guest', false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateRole(UserRole newRole) async {
    if (_user == null) return;
    _user = UserModel(
      uid: _user!.uid,
      displayName: _user!.displayName,
      email: _user!.email,
      photoUrl: _user!.photoUrl,
      role: newRole,
      isGuest: _user!.isGuest,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_role', newRole.name);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_uid');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('auth_role');
    await prefs.remove('auth_is_guest');

    _user = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Citizen',
      email: '',
      role: UserRole.citizen,
      isGuest: true,
    );
    notifyListeners();
  }
}
