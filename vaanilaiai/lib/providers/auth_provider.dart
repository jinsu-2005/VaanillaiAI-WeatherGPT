import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

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

  static UserRole roleFromString(String? roleStr) {
    if (roleStr == null) return UserRole.citizen;
    for (final role in UserRole.values) {
      if (role.name.toLowerCase() == roleStr.toLowerCase()) {
        return role;
      }
    }
    return UserRole.citizen;
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && !_user!.isGuest;
  bool get isGuest => _user != null && _user!.isGuest;
  String? get errorMessage => _errorMessage;

  AuthService get authService => _authService;
  FirestoreService get firestoreService => _firestoreService;

  AuthProvider() {
    _initAuth();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _initAuth() async {
    // 1. Initial quick load from local preferences
    await _loadUserFromPrefs();

    // 2. Subscribe to Firebase reactive auth state changes
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _syncFromFirebaseUser(firebaseUser);
      } else {
        // Only revert to guest if not already a designated guest
        if (_user == null || !_user!.isGuest) {
          _setGuestUser();
        }
      }
    });
  }

  Future<void> _syncFromFirebaseUser(User firebaseUser, {UserRole? overrideRole}) async {
    try {
      final firestoreData = await _firestoreService.fetchUserProfile(firebaseUser.uid);

      UserRole role = overrideRole ?? UserRole.citizen;
      if (overrideRole == null && firestoreData != null && firestoreData['role'] != null) {
        role = UserModel.roleFromString(firestoreData['role']);
      } else if (overrideRole == null) {
        final prefs = await SharedPreferences.getInstance();
        final cachedRole = prefs.getString('auth_role');
        if (cachedRole != null) {
          role = UserModel.roleFromString(cachedRole);
        }
      }

      final name = firebaseUser.displayName ??
          firestoreData?['displayName'] ??
          (firebaseUser.email != null ? firebaseUser.email!.split('@')[0] : 'Citizen');

      _user = UserModel(
        uid: firebaseUser.uid,
        displayName: name,
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        role: role,
        isGuest: false,
      );

      // Persist to local preferences
      await _persistUserToPrefs(_user!);

      // Sync with Firestore
      await _firestoreService.syncUserProfile(_user!);

      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing Firebase user: $e');
    }
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('auth_uid');
      final name = prefs.getString('auth_name');
      final email = prefs.getString('auth_email');
      final roleStr = prefs.getString('auth_role');
      final photoUrl = prefs.getString('auth_photo');
      final isGuest = prefs.getBool('auth_is_guest') ?? true;

      if (uid != null && name != null && !isGuest) {
        _user = UserModel(
          uid: uid,
          displayName: name,
          email: email ?? '',
          photoUrl: photoUrl,
          role: UserModel.roleFromString(roleStr),
          isGuest: false,
        );
      } else {
        _setGuestUser();
      }
    } catch (_) {
      _setGuestUser();
    }
    notifyListeners();
  }

  void _setGuestUser() {
    _user = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Citizen',
      email: '',
      role: UserRole.citizen,
      isGuest: true,
    );
    notifyListeners();
  }

  Future<void> _persistUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_uid', user.uid);
    await prefs.setString('auth_name', user.displayName);
    await prefs.setString('auth_email', user.email);
    await prefs.setString('auth_role', user.role.name);
    if (user.photoUrl != null) {
      await prefs.setString('auth_photo', user.photoUrl!);
    } else {
      await prefs.remove('auth_photo');
    }
    await prefs.setBool('auth_is_guest', user.isGuest);
  }

  // --- 1. Sign In with Google ---
  Future<bool> signInWithGoogle({UserRole role = UserRole.citizen}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null || credential.user == null) {
        // User cancelled popup/prompt
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _syncFromFirebaseUser(credential.user!, overrideRole: role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthService.getFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 2. Sign Up with Email & Password ---
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.citizen,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (credential.user == null) {
        _errorMessage = 'Failed to create user account. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _syncFromFirebaseUser(credential.user!, overrideRole: role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthService.getFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 3. Sign In with Email & Password ---
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        _errorMessage = 'Failed to sign in. Please verify your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _syncFromFirebaseUser(credential.user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthService.getFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 4. Password Reset ---
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthService.getFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 5. Role Update ---
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

    if (!_user!.isGuest) {
      await _firestoreService.updateUserRole(_user!.uid, newRole);
    }

    notifyListeners();
  }

  // --- 6. Guest Sign-In ---
  Future<void> signInAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _setGuestUser();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_uid', _user!.uid);
    await prefs.setString('auth_name', _user!.displayName);
    await prefs.setBool('auth_is_guest', true);

    _isLoading = false;
    notifyListeners();
  }

  // --- 7. Sign Out ---
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_uid');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('auth_role');
    await prefs.remove('auth_photo');
    await prefs.remove('auth_is_guest');

    _setGuestUser();
    _isLoading = false;
    notifyListeners();
  }
}
