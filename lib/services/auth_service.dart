import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_todo_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    }
    return null;
  }

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign up with name, email and password
  Future<User?> signUpWithEmail(
      String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Save user profile with username and default profile picture
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
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);

      // Fetch Google profile picture
      final user = result.user;
      if (user != null) {
        await _saveUserProfile(
          user.uid,
          user.displayName ?? 'Anonymous',
          user.email!,
          user.photoURL,
        );
      }

      return user;
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(user.toMap());
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
