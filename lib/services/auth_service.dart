import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': DateTime.now().toUtc().toString(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return getCurrentUser();
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        final userData = {
          'id': user.uid,
          'email': email,
          'displayName': name,
          'photoURL': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': DateTime.now().toUtc().toString(),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);
        await user.updateDisplayName(name);

        return getCurrentUser();
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          final userData = {
            'id': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? 'User',
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'lastLogin': DateTime.now().toUtc().toString(),
          };
          await _firestore.collection('users').doc(user.uid).set(userData);
        } else {
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': DateTime.now().toUtc().toString(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return getCurrentUser();
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<UserModel?> updateProfile({
    required String userId,
    required String displayName,
  }) async {
    try {
      // Update Firebase Auth display name
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(displayName);
      }

      // Update Firestore user document
      await _firestore.collection('users').doc(userId).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user
      return getCurrentUser();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
