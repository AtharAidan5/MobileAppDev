import 'dart:io';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;

class PdfStorageService {
  // Generate PDF and return as base64 string (stored in Firestore)
  Future<String> generateAndEncodePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Certificate',
                style:
                    pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Name: ${data['name']}'),
            pw.Text('Recipient: ${data['recipient']}'),
            pw.Text('Organization: ${data['organization']}'),
            pw.Text('Purpose: ${data['purpose']}'),
            pw.Text(
                'Issued: ${data['issuedDate'] != null ? (data['issuedDate'] as dynamic).toDate().toString().split(' ').first : ''}'),
            pw.Text(
                'Expiry: ${data['expiryDate'] != null ? (data['expiryDate'] as dynamic).toDate().toString().split(' ').first : ''}'),
            pw.SizedBox(height: 24),
            pw.Text('Signature:'),
            pw.Text(data['signature'] ?? ''),
          ],
        ),
      ),
    );

    final pdfBytes = await pdf.save();
    final base64String = base64Encode(pdfBytes);

    return base64String;
  }

  // Decode base64 PDF and return as bytes
  List<int> decodePdf(String base64String) {
    return base64Decode(base64String);
  }

  // Create a data URL for viewing in browser
  String createDataUrl(String base64String) {
    return 'data:application/pdf;base64,$base64String';
  }

  // Save PDF to temporary file (for download)
  Future<File> savePdfToFile(String base64String, String fileName) async {
    final pdfBytes = decodePdf(base64String);
    final file = File('${Directory.systemTemp.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file;
  }
}
