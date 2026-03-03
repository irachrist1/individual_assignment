import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  UserProfile? _userProfile;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _user = null;
      _userProfile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    // Reload to get the latest emailVerified value
    await user.reload();
    _user = _authService.currentUser;
    if (_user != null && _user!.emailVerified) {
      _userProfile = await _authService.getUserProfile(_user!.uid);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      // After signup, user must verify email — set unauthenticated
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authService.signIn(email: email, password: password);
      if (_user == null) {
        _errorMessage = 'Login failed. Please try again.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      // Enforce email verification
      if (!_user!.emailVerified) {
        _errorMessage = 'Please verify your email before logging in.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      _userProfile = await _authService.getUserProfile(_user!.uid);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Poll Firebase to check if user has verified their email
  Future<void> checkEmailVerification() async {
    await _authService.reloadUser();
    _user = _authService.currentUser;
    if (_user != null && _user!.emailVerified) {
      _userProfile = await _authService.getUserProfile(_user!.uid);
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    await _authService.sendEmailVerification();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
