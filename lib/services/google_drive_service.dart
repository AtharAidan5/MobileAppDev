import 'dart:io';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];

  // You'll need to get these from Google Cloud Console
  static const String _clientId = 'YOUR_CLIENT_ID.apps.googleusercontent.com';
  static const String _clientSecret = 'YOUR_CLIENT_SECRET';

  drive.DriveApi? _driveApi;

  // Initialize the service
  Future<void> initialize() async {
    if (_driveApi != null) return;

    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "your-project-id",
      "private_key_id": "your-private-key-id",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
      "client_email":
          "your-service-account@your-project.iam.gserviceaccount.com",
      "client_id": "your-client-id",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/your-service-account%40your-project.iam.gserviceaccount.com"
    });

    final client = await clientViaServiceAccount(credentials, _scopes);
    _driveApi = drive.DriveApi(client);
  }

  // Upload PDF to Google Drive
  Future<String> uploadPdf(File pdfFile, String fileName) async {
    await initialize();

    final file = drive.File()
      ..name = fileName
      ..parents = ['root']; // Upload to root folder

    final media = drive.Media(
      pdfFile.openRead(),
      await pdfFile.length(),
    );

    final uploadedFile =
        await _driveApi!.files.create(file, uploadMedia: media);

    // Make the file publicly readable
    await _driveApi!.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploadedFile.id!,
    );

    // Return the public download URL
    return 'https://drive.google.com/uc?export=download&id=${uploadedFile.id}';
  }

  // Get file by ID
  Future<drive.File?> getFile(String fileId) async {
    await initialize();
    try {
      return await _driveApi!.files.get(fileId) as drive.File;
    } catch (e) {
      print('Error getting file: $e');
      return null;
    }
  }

  // Delete file
  Future<void> deleteFile(String fileId) async {
    await initialize();
    try {
      await _driveApi!.files.delete(fileId);
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
