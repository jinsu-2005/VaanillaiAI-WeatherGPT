import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    if (!kIsWeb) {
      try {
        GoogleSignIn.instance.initialize();
      } catch (e) {
        debugPrint('GoogleSignIn initialization error: $e');
      }
    }
  }

  /// Stream to listen to reactive auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently authenticated Firebase user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google (Cross-platform: Web popup, Mobile SDK credential)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error during Google Sign-In: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during Google Sign-In: $e');
      rethrow;
    }
  }

  /// Sign up with Email and Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error during Sign-Up: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign in with Email and Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error during Sign-In: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error sending reset email: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Graceful sign out across Mobile and Web
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  /// User-friendly error message resolution for UI display
  static String getFriendlyErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address. Please sign up.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password. Please verify your credentials.';
        case 'email-already-in-use':
          return 'An account already exists for this email address. Please sign in instead.';
        case 'invalid-email':
          return 'Please provide a valid email address.';
        case 'weak-password':
          return 'The password must be at least 6 characters long.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few moments and try again.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact administrator.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'popup-closed-by-user':
          return 'Google Sign-In popup was closed before completing.';
        case 'unauthorized-domain':
          return 'This domain is not authorized for OAuth. Please check authorized domains.';
        default:
          return error.message ?? 'An authentication error occurred (${error.code}).';
      }
    }
    return error.toString();
  }
}
