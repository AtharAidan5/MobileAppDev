# PDF Generation Debug Guide

## Why PDFs Might Not Be Appearing

The PDF generation process involves several steps that could fail:

### 1. **Firebase Storage Permissions**
- Check if your Firebase project has Storage enabled
- Verify Storage security rules allow uploads
- Make sure you're authenticated when uploading

### 2. **PDF Generation Process**
The process is:
1. **Create certificate** → Save to Firestore (fast)
2. **Generate PDF** → Create PDF file locally
3. **Upload to Firebase Storage** → Upload PDF file
4. **Update Firestore** → Add PDF URL to certificate document

### 3. **Debug Steps**

#### Step 1: Check Console Logs
When you create a certificate, look for these debug messages:
```
DEBUG: Starting PDF generation...
DEBUG: PDF file created at: /path/to/file.pdf
DEBUG: PDF file size: 1234 bytes
DEBUG: Uploading PDF to Firebase Storage...
DEBUG: PDF uploaded successfully. URL: https://...
DEBUG: Updating Firestore with PDF URL...
DEBUG: Firestore updated successfully
```

#### Step 2: Check Firebase Storage
1. Go to **Firebase Console** → **Storage**
2. Look for files in `certificates/ca/` folder
3. Check if PDF files are being uploaded

#### Step 3: Check Firestore
1. Go to **Firebase Console** → **Firestore**
2. Look at your certificate documents
3. Check if `pdfUrl` field exists and has a value

### 4. **Manual PDF Generation**

If automatic PDF generation fails, you can manually generate PDFs:

1. **Go to Certificates** screen
2. **Tap on a certificate** that doesn't have a PDF
3. **Tap "Generate PDF Now"** button
4. **Check console** for any error messages

### 5. **Common Issues & Solutions**

#### Issue: "PDF upload failed"
**Possible causes:**
- Firebase Storage not enabled
- Storage security rules too restrictive
- Network connectivity issues
- File size too large

**Solutions:**
- Enable Firebase Storage in console
- Update Storage security rules
- Check internet connection
- Reduce PDF file size

#### Issue: "PDF URL not saved"
**Possible causes:**
- Firestore update failed
- Share token mismatch
- Permission denied

**Solutions:**
- Check Firestore security rules
- Verify user authentication
- Check console for specific errors

### 6. **Firebase Storage Security Rules**

Make sure your Storage rules allow uploads:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /certificates/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 7. **Testing PDF Generation**

1. **Create a test certificate** with PDF generation enabled
2. **Watch the console logs** for debug messages
3. **Check Firebase Storage** for uploaded files
4. **Check Firestore** for PDF URL field
5. **Try viewing the PDF** in the certificate viewer

### 8. **Alternative Solutions**

If PDF generation continues to fail:

1. **Disable PDF generation** temporarily (toggle off)
2. **Save certificates without PDFs** (still works)
3. **Use manual PDF generation** for important certificates
4. **Check Firebase project settings** and billing

### 9. **Getting Help**

If you're still having issues:

1. **Check the console logs** for specific error messages
2. **Verify Firebase project setup** (Storage, Firestore, Auth)
3. **Test with a simple certificate** first
4. **Check network connectivity** and Firebase status

The certificate functionality works without PDFs, so you can continue using the app while debugging PDF generation! 