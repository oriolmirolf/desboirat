import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current User ID
  String? get uid => _auth.currentUser?.uid;

  // 1. Link Patient to Doctor
  Future<void> linkDoctor(String doctorId) async {
    if (uid == null) return;
    
    await _db.collection('users').doc(uid).set({
      'doctorId': doctorId,
      'lastActive': DateTime.now(),
      'email': _auth.currentUser?.email,
    }, SetOptions(merge: true));
  }

  // 2. Check if linked
  Future<bool> isLinkedToDoctor() async {
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['doctorId'] != null;
  }

  // 3. Save Test Results
  Future<void> saveResult(String testName, Map<String, dynamic> data) async {
    if (uid == null) return;

    // Save to a sub-collection 'results' under the user
    await _db.collection('users').doc(uid).collection('results').add({
      'testName': testName,
      'timestamp': DateTime.now(),
      ...data, // Spreads the score data (e.g. {'score': 5, 'details': '...'})
    });
  }
}