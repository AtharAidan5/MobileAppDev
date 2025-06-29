import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a certificate
  Future<void> addCertificate(Map<String, dynamic> data) async {
    await _db.collection('certificates').add(data);
  }

  // Get all certificates (no userId filter)
  Stream<QuerySnapshot> getCertificates() {
    return _db.collection('certificates').snapshots();
  }

  // Optionally: get a single certificate by ID
  Future<DocumentSnapshot> getCertificate(String id) async {
    return await _db.collection('certificates').doc(id).get();
  }
}
