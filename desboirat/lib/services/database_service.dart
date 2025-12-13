import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // --- LINK DOCTOR (For QR Code) ---
  Future<void> linkDoctor(String doctorUID) async {
    if (uid == null) return;
    
    // Save the link AND the email so the doctor sees the patient's name
    await _db.collection('users').doc(uid).set({
      'doctorId': doctorUID,
      'email': _auth.currentUser?.email, 
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); 
  }

  Future<bool> isLinkedToDoctor() async {
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['doctorId'] != null;
  }

  // --- SAVE RESULTS (Universal Method) ---
  Future<void> saveResult(String testName, Map<String, dynamic> data) async {
    if (uid == null) return;

    await _db.collection('users').doc(uid).collection('results').add({
      'testName': testName,
      'timestamp': FieldValue.serverTimestamp(), // Server time is best for sorting
      ...data,
    });
  }
}