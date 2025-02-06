import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDeleteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> deleteUserData(String userId) async {

    WriteBatch batch = _firestore.batch();

    try {
      // Delete user's tasks
      final tasksDocs = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in tasksDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's categories
      final categoriesDocs = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in categoriesDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(_firestore.collection('users').doc(userId));

      await batch.commit();
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
}