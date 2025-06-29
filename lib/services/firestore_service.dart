import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

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

  // Update certificate status (approve/reject)
  Future<void> updateCertificateStatus(String certId, String status,
      {String? approver}) async {
    await _db.collection('certificates').doc(certId).update({
      'status': status,
      if (approver != null) 'approver': approver,
      if (status == 'approved') 'approvalDate': FieldValue.serverTimestamp(),
    });
  }

  // Update certificate PDF URL
  Future<void> updateCertificatePdfUrl(String shareToken, String pdfUrl) async {
    final query = await _db
        .collection('certificates')
        .where('shareToken', isEqualTo: shareToken)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'pdfUrl': pdfUrl,
        'pdfUploadedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update certificate PDF data (base64)
  Future<void> updateCertificatePdfData(
      String shareToken, String pdfBase64) async {
    final query = await _db
        .collection('certificates')
        .where('shareToken', isEqualTo: shareToken)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'pdfBase64': pdfBase64,
        'pdfGeneratedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get pending certificates (for approval)
  Stream<QuerySnapshot> getPendingCertificates() {
    return _db
        .collection('certificates')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Generate a unique share token
  String generateShareToken([int length = 16]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // Get certificate by share token
  Future<DocumentSnapshot?> getCertificateByToken(String token) async {
    final query = await _db
        .collection('certificates')
        .where('shareToken', isEqualTo: token)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  // Log certificate action
  Future<void> logCertificateAction({
    required String certId,
    required String action,
    required String userEmail,
    String? details,
  }) async {
    await _db.collection('certificate_logs').add({
      'certId': certId,
      'action': action,
      'userEmail': userEmail,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
