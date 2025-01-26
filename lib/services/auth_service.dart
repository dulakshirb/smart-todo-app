import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_todo_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null;
    }
    return null;
  }

  // Sign in with email
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign up with email
  Future<User?> signUpWithEmail(
      String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (result.user != null) {
        await _saveUserProfile(
          result.user!.uid,
          name,
          email,
          null,
        );
      }

      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          await _saveUserProfile(
            user.uid,
            user.displayName ?? 'Anonymous',
            user.email!,
            user.photoURL,
          );
        }

        final updatedDoc =
            await _firestore.collection('users').doc(user.uid).get();
        return updatedDoc.exists
            ? UserModel.fromMap(updatedDoc.data()!, updatedDoc.id)
            : null;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Save user profile to Firestore
  Future<void> _saveUserProfile(
      String userId, String name, String email, String? profileImageUrl) async {
    final user = UserModel(
      id: userId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
    );
    await _firestore.collection('users').doc(userId).set(user.toMap());
  }

  // Sign out
  Future<void> signOut() async => await _auth.signOut();

  // Update profile
  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Delete user from Firestore and Firebase Auth
  Future<void> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
