import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();

    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
      } else {
        _user = await _authService.getCurrentUser();
        notifyListeners();
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithEmailAndPassword(email, password);
      notifyListeners();
    } catch (e) {
      _error = _getReadableErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signUpWithEmailAndPassword(
        name,
        email,
        password,
      );
      notifyListeners();
    } catch (e) {
      _error = _getReadableErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.signInWithGoogle();
      notifyListeners();
    } catch (e) {
      _error = _getReadableErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) throw Exception('No user logged in');

      _user = await _authService.updateProfile(
        userId: _user!.id,
        displayName: displayName,
      );

      notifyListeners();
    } catch (e) {
      _error = _getReadableErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) throw Exception('No user logged in');

      await _authService.deleteProfile(userId: _user!.id);
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = _getReadableErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'requires-recent-login':
          return 'Please sign in again to delete your account.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'An error occurred. Please try again.';
      }
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An error occurred. Please try again.';
  }
}
