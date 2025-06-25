import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file and return its download URL
  Future<String> uploadCertificateFile(File file, String userId) async {
    final ref = _storage.ref().child('certificates').child(userId).child(
        DateTime.now().millisecondsSinceEpoch.toString() +
            '_' +
            file.path.split('/').last);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
