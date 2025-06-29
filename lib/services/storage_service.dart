import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
// We no longer need auth_service.dart here

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to a public folder and returns its download URL.
  Future<String> uploadCertificateFile(File file) async {
    // REMOVED: The user check 'if (user == null)' is gone.

    // Create a unique file path in a general public folder.
    final String filePath =
        'public_certificates/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child(filePath);

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
