import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Google Sign-In with UPM email restriction
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    // Restrict to UPM email
    if (!(googleUser.email.endsWith('@upm.edu.my') ||
        googleUser.email.endsWith('@student.upm.edu.my'))) {
      await GoogleSignIn().signOut();
      throw Exception('Only UPM emails are allowed.');
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user doc exists with Google Auth UID
    final userDoc = _db.collection('users').doc(userCredential.user!.uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      // Check if there's an existing user with the same email
      final emailQuery = await _db
          .collection('users')
          .where('email', isEqualTo: userCredential.user!.email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        // Found existing user with same email, update the UID
        final existingUser = emailQuery.docs.first;
        final existingData = existingUser.data();

        // Create new document with Google Auth UID
        await userDoc.set({
          ...existingData,
          'uid': userCredential.user!.uid, // Update UID reference
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Delete the old document
        await existingUser.reference.delete();
      } else {
        // Create new user
        await userDoc.set({
          'email': userCredential.user!.email,
          'role': 'recipient', // default role
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // Update last login for existing user
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
    return userCredential;
  }

  // Update last login for any user
  Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  // Set user role (admin only)
  Future<void> setUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).update({'role': role});
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // Create admin user manually
  Future<void> createAdminUser({
    required String uid,
    required String email,
    String role = 'admin',
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isAdmin': true,
    });
  }

  // Create admin user with auto-generated UID
  Future<String> createAdminUserWithEmail({
    required String email,
    String role = 'admin',
  }) async {
    // Generate a unique document ID
    final userDoc = _db.collection('users').doc();
    final uid = userDoc.id;

    await userDoc.set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isAdmin': true,
      'uid': uid, // Store the UID in the document for reference
    });

    return uid;
  }

  // Link current Google Auth user to existing admin user
  Future<void> linkCurrentUserToAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    // Find existing admin user with the same email
    final emailQuery = await _db
        .collection('users')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (emailQuery.docs.isEmpty) {
      throw Exception('No admin user found with email: ${currentUser.email}');
    }

    final existingUser = emailQuery.docs.first;
    final existingData = existingUser.data();

    // Create new document with Google Auth UID
    final newUserDoc = _db.collection('users').doc(currentUser.uid);
    await newUserDoc.set({
      ...existingData,
      'uid': currentUser.uid, // Update UID reference
      'lastLogin': FieldValue.serverTimestamp(),
    });

    // Delete the old document
    await existingUser.reference.delete();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
