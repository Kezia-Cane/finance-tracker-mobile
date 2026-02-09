import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService - Handles all authentication operations
/// 
/// Provides methods for:
/// - User registration
/// - User login
/// - User logout
/// - Password reset
/// - Session management
class AuthService {
  /// Supabase client instance
  static SupabaseClient get _client => Supabase.instance.client;

  /// Get the current user (null if not logged in)
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Sign up a new user with email and password
  /// 
  /// Returns the user if successful, throws an exception otherwise.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Sign in with email and password
  /// 
  /// Returns the auth response if successful, throws an exception otherwise.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Get the user's display name
  static String? get displayName {
    final data = currentUser?.userMetadata;
    return data?['full_name'] as String?;
  }

  /// Get the user's email
  static String? get email => currentUser?.email;
}
