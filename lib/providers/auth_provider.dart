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
    _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (_) {
        _status = AuthStatus.error;
        _errorMessage = 'Authentication error. Please try again.';
        notifyListeners();
      },
    );
  }

  /// Single source of truth for auth state. Called by Firebase whenever the
  /// signed-in user changes (sign-in, sign-out, token refresh, etc.).
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _user = null;
      _userProfile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    // Reload to get the latest emailVerified value from Firebase.
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
      final user = await _authService.signIn(email: email, password: password);
      if (user == null) {
        _errorMessage = 'Login failed. Please try again.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
      // Enforce email verification before allowing access.
      if (!user.emailVerified) {
        _errorMessage = 'Please verify your email before logging in.';
        _status = AuthStatus.error;
        notifyListeners();
        // Sign out so Firebase doesn't leave an active unverified session.
        await _authService.signOut();
        return false;
      }
      // Firebase will fire authStateChanges → _onAuthStateChanged will update
      // _user, _userProfile, and _status = authenticated. Not done here to
      // avoid racing with _onAuthStateChanged and double-notifying listeners.
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    // _onAuthStateChanged(null) will fire and clear _user / _userProfile /
    // _status. Manually clearing here too ensures the UI reacts immediately
    // even if the stream fires slightly later.
    _user = null;
    _userProfile = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    await _authService.signOut();
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
