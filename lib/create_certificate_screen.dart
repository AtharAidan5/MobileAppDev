import 'package:flutter/material.dart';

class CreateCertificateScreen extends StatefulWidget {
  const CreateCertificateScreen({super.key});

  @override
  State<CreateCertificateScreen> createState() =>
      _CreateCertificateScreenState();
}

class _CreateCertificateScreenState extends State<CreateCertificateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  DateTime? _issuedDate;
  DateTime? _expiryDate;

  String? _signatureText = "CA Signature";

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issuedDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  void _saveCertificate() {
    // You can add validation or store this data later
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Certificate saved!')));

    // Navigate back after saving
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Certificate")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Certificate Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(labelText: "Recipient Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _organizationController,
              decoration: const InputDecoration(labelText: "Organization"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(labelText: "Purpose"),
            ),
            const SizedBox(height: 12),

            ListTile(
              title: const Text("Date Issued"),
              subtitle: Text(
                _issuedDate?.toLocal().toString().split(' ').first ??
                    'Not selected',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),

            ListTile(
              title: const Text("Expiry Date"),
              subtitle: Text(
                _expiryDate?.toLocal().toString().split(' ').first ??
                    'Not selected',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),

            const SizedBox(height: 16),

            const Text(
              "Digital Signature",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _signatureText,
              onChanged: (value) {
                setState(() {
                  _signatureText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: "Enter CA name or signature",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveCertificate,
              child: const Text("Save Certificate"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipientController.dispose();
    _organizationController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}
