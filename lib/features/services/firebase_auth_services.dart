import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireBaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Sign up
  Future<String?> signUp(
      String email,
      String password,
      String firstName,
      String surname,
      String schoolName,
      String schoolLga,
      String contactName,
      String contactPhone,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final now = Timestamp.now();

      // Save user to users collection
      await _fireStore.collection('users').doc(uid).set({
        'firstName': firstName,
        'surname': surname,
        'email': email,
        'schoolName': schoolName,
        'createdAt': now,
      });

      // Save user under their school in schools collection
      // Document ID is school name lowercased with underscores
      final schoolDocId = schoolName.toLowerCase().replaceAll(' ', '_');

      // Upsert school document with latest info
      await _fireStore.collection('schools').doc(schoolDocId).set({
        'name': schoolName,
        'lga': schoolLga,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'updatedAt': now,
      }, SetOptions(merge: true));

      // Add user as a member under the school
      await _fireStore
          .collection('schools')
          .doc(schoolDocId)
          .collection('members')
          .doc(uid)
          .set({
        'uid': uid,
        'firstName': firstName,
        'surname': surname,
        'email': email,
        'joinedAt': now,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'Sign up failed. Please try again.';
      }
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }
  // Login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check and try again.';
        default:
          return 'Login failed. Please try again.';
      }
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  /// Forgot password function
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'Failed to send reset email. Please try again.';
      }
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }


  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Current user
  User? get currentUser => _auth.currentUser;
}
