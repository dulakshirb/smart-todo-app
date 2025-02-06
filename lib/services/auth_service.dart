import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dd_smart_todo_app/services/profile_delete_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ProfileDeleteService _profileDeleteService = ProfileDeleteService();

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

  Future<UserModel?> updateProfile({
    required String userId,
    required String displayName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(displayName);
      }

      await _firestore.collection('users').doc(userId).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return getCurrentUser();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> deleteProfile({required String userId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Check if user needs to be re-authenticated
      try {
        // Try to get user reauthenticated if using Google
        if (await _googleSignIn.isSignedIn()) {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(credential);
          }
        }

        // Delete all user data first
        await _profileDeleteService.deleteUserData(userId);

        // Then delete the Firebase Auth user
        await user.delete();

        // Finally, sign out from Google if applicable
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw FirebaseAuthException(
            code: 'requires-recent-login',
            message:
                'Please sign in again to delete your account for security reasons.',
          );
        }
        rethrow;
      }
    } catch (e) {
      print('Error in AuthService.deleteProfile: $e');
      rethrow;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
