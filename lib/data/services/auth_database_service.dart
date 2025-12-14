import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// A local database service for user authentication.
/// This provides real sign up, sign in, and password reset functionality
/// using a local SQLite database.
class AuthDatabaseService {
  static final AuthDatabaseService _instance = AuthDatabaseService._internal();
  factory AuthDatabaseService() => _instance;
  AuthDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_tracker_auth.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            display_name TEXT,
            created_at TEXT NOT NULL,
            last_login TEXT,
            reset_token TEXT,
            reset_token_expiry TEXT
          )
        ''');
      },
    );
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a random reset token
  String _generateResetToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8).toUpperCase();
  }

  /// Sign up a new user
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final db = await database;
      
      // Check if email already exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (existing.isNotEmpty) {
        return AuthResult(
          success: false,
          error: 'An account with this email already exists',
        );
      }

      // Create user
      final now = DateTime.now().toIso8601String();
      final passwordHash = _hashPassword(password);

      final id = await db.insert('users', {
        'email': email.toLowerCase(),
        'password_hash': passwordHash,
        'display_name': displayName ?? email.split('@').first,
        'created_at': now,
        'last_login': now,
      });

      return AuthResult(
        success: true,
        userId: id.toString(),
        email: email.toLowerCase(),
        displayName: displayName ?? email.split('@').first,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to create account: ${e.toString()}',
      );
    }
  }

  /// Sign in an existing user
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final db = await database;
      
      // Find user by email
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (users.isEmpty) {
        return AuthResult(
          success: false,
          error: 'No account found with this email',
        );
      }

      final user = users.first;
      final storedHash = user['password_hash'] as String;
      final inputHash = _hashPassword(password);

      if (storedHash != inputHash) {
        return AuthResult(
          success: false,
          error: 'Incorrect password',
        );
      }

      // Update last login
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      return AuthResult(
        success: true,
        userId: user['id'].toString(),
        email: user['email'] as String,
        displayName: user['display_name'] as String?,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to sign in: ${e.toString()}',
      );
    }
  }

  /// Request password reset - generates a token
  Future<AuthResult> requestPasswordReset(String email) async {
    try {
      final db = await database;
      
      // Find user by email
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (users.isEmpty) {
        return AuthResult(
          success: false,
          error: 'No account found with this email',
        );
      }

      // Generate reset token (valid for 1 hour)
      final resetToken = _generateResetToken();
      final expiry = DateTime.now().add(const Duration(hours: 1)).toIso8601String();

      await db.update(
        'users',
        {
          'reset_token': resetToken,
          'reset_token_expiry': expiry,
        },
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      return AuthResult(
        success: true,
        resetToken: resetToken,
        message: 'Your reset code is: $resetToken\n\nUse this code to reset your password.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to process reset request: ${e.toString()}',
      );
    }
  }

  /// Reset password using token
  Future<AuthResult> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final db = await database;
      
      // Find user by email
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (users.isEmpty) {
        return AuthResult(
          success: false,
          error: 'No account found with this email',
        );
      }

      final user = users.first;
      final storedToken = user['reset_token'] as String?;
      final expiryStr = user['reset_token_expiry'] as String?;

      if (storedToken == null || storedToken != token.toUpperCase()) {
        return AuthResult(
          success: false,
          error: 'Invalid reset code',
        );
      }

      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isAfter(expiry)) {
          return AuthResult(
            success: false,
            error: 'Reset code has expired. Please request a new one.',
          );
        }
      }

      // Update password and clear reset token
      final passwordHash = _hashPassword(newPassword);
      await db.update(
        'users',
        {
          'password_hash': passwordHash,
          'reset_token': null,
          'reset_token_expiry': null,
        },
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      return AuthResult(
        success: true,
        message: 'Password reset successfully! You can now sign in with your new password.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to reset password: ${e.toString()}',
      );
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty;
  }

  /// Delete user account
  Future<bool> deleteAccount(String email) async {
    try {
      final db = await database;
      await db.delete(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Result class for auth operations
class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? error;
  final String? resetToken;
  final String? message;

  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.displayName,
    this.error,
    this.resetToken,
    this.message,
  });
}
