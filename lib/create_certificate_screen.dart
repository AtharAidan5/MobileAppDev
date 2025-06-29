import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[300]!
                  : Colors.blue[700]!,
            ),
          ),
          child: child!,
        );
      },
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

  void _saveCertificate() async {
    final data = {
      'name': _nameController.text,
      'recipient': _recipientController.text,
      'organization': _organizationController.text,
      'purpose': _purposeController.text,
      'issuedDate':
          _issuedDate != null ? Timestamp.fromDate(_issuedDate!) : null,
      'expiryDate':
          _expiryDate != null ? Timestamp.fromDate(_expiryDate!) : null,
      'signature': _signatureText ?? '',
    };
    await FirestoreService().addCertificate(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Certificate saved!',
          style: GoogleFonts.inter(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Certificate",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Certificate Details",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.24,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _nameController,
                      label: "Certificate Name",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _recipientController,
                      label: "Recipient Name",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _organizationController,
                      label: "Organization",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _purposeController,
                      label: "Purpose",
                      isDark: isDark,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    _buildDateField(
                      title: "Date Issued",
                      value: _issuedDate,
                      onTap: () => _selectDate(context, true),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      title: "Expiry Date",
                      value: _expiryDate,
                      onTap: () => _selectDate(context, false),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Digital Signature",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _signatureText,
                      onChanged: (value) {
                        setState(() {
                          _signatureText = value;
                        });
                      },
                      style: GoogleFonts.inter(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter CA name or signature",
                        hintStyle: GoogleFonts.inter(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.blue[300]! : Colors.blue[700]!,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveCertificate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.blue[700] : Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save Certificate",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    int maxLines = 1,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.blue[300]! : Colors.blue[700]!,
          ),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
      ),
    );
  }

  Widget _buildDateField({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[800] : Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value?.toLocal().toString().split(' ').first ??
                        'Not selected',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 16,
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
