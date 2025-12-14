import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_database_service.dart';

/// Authentication state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication provider for user login/signup functionality.
/// Uses a local SQLite database for real authentication.
class AuthProvider extends ChangeNotifier {
  final AuthDatabaseService _authDb = AuthDatabaseService();
  
  AuthState _state = AuthState.initial;
  String? _userId;
  String? _userEmail;
  String? _displayName;
  String? _error;
  String? _successMessage;

  // Email validation pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Getters
  AuthState get state => _state;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get displayName => _displayName;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Validate email format
  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  /// Initialize auth provider - check for existing session
  Future<void> init() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('auth_user_id');
      final storedEmail = prefs.getString('auth_user_email');
      final storedName = prefs.getString('auth_display_name');

      if (storedUserId != null && storedEmail != null) {
        _userId = storedUserId;
        _userEmail = storedEmail;
        _displayName = storedName;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Attempt sign in with database
      final result = await _authDb.signIn(
        email: email,
        password: password,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Sign in failed');
      }

      _userId = result.userId;
      _userEmail = result.email;
      _displayName = result.displayName;

      // Persist auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);
      await prefs.setString('auth_user_email', _userEmail!);
      if (_displayName != null) {
        await prefs.setString('auth_display_name', _displayName!);
        await prefs.setString('user_name', _displayName!);
      }

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _state = AuthState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Attempt sign up with database
      final result = await _authDb.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Sign up failed');
      }

      _userId = result.userId;
      _userEmail = result.email;
      _displayName = result.displayName;

      // Persist auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);
      await prefs.setString('auth_user_email', _userEmail!);
      if (_displayName != null) {
        await prefs.setString('auth_display_name', _displayName!);
        await prefs.setString('user_name', _displayName!);
      }

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_user_email');
      await prefs.remove('auth_display_name');

      _userId = null;
      _userEmail = null;
      _displayName = null;
      _state = AuthState.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    _successMessage = null;
    if (_state == AuthState.error) {
      _state = _userId != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Skip authentication (continue as guest)
  Future<void> continueAsGuest() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Generate a guest user ID
      _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = null;
      _displayName = 'Guest';

      // Persist guest state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', _userId!);

      _state = AuthState.authenticated;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
    }

    notifyListeners();
  }

  /// Request password reset - returns a reset code
  Future<bool> forgotPassword({required String email}) async {
    _state = AuthState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Request password reset
      final result = await _authDb.requestPasswordReset(email);

      if (!result.success) {
        throw Exception(result.error ?? 'Password reset request failed');
      }

      _successMessage = result.message;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Reset password using the reset code
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _state = AuthState.loading;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Basic validation
      if (email.isEmpty || !_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }
      if (token.isEmpty) {
        throw Exception('Please enter the reset code');
      }
      if (newPassword.isEmpty || newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Reset password
      final result = await _authDb.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Password reset failed');
      }

      _successMessage = result.message;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google (placeholder)
  Future<bool> signInWithGoogle() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _error = 'Google Sign-In is not yet configured. Please use email sign in.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Apple (placeholder)
  Future<bool> signInWithApple() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _error = 'Apple Sign-In is not yet configured. Please use email sign in.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    if (_userEmail == null) return false;

    _state = AuthState.loading;
    notifyListeners();

    try {
      await _authDb.deleteAccount(_userEmail!);
      await signOut();
      return true;
    } catch (e) {
      _error = e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
}
