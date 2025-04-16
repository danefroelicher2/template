// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1034418380087-63kdv2ic6147ib9mbrlc7bvo34qk3l4m.apps.googleusercontent.com',
  );

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID safely
  String get userId => _auth.currentUser?.uid ?? 'guest';

  // Check if user is anonymous (guest mode)
  bool get isGuest => _auth.currentUser?.isAnonymous ?? true;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null && !isGuest;

  // SIGN UP WITH EMAIL
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      // Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create user profile in Firestore
      await _createUserProfile(userCredential.user!);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific error cases
      if (e.code == 'weak-password') {
        throw AuthException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('An account already exists for that email.');
      } else {
        throw AuthException(e.message ?? 'Failed to create account.');
      }
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  // SIGN IN WITH EMAIL
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user's last login timestamp
      await _updateLastLogin(userCredential.user!);

      // Sync subscription status
      await _syncSubscriptionStatus(userCredential.user!);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Incorrect password.');
      } else {
        throw AuthException(e.message ?? 'Failed to sign in.');
      }
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  // SIGN IN WITH GOOGLE
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Google sign-in was cancelled.');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        await _createUserProfile(userCredential.user!);
      } else {
        await _updateLastLogin(userCredential.user!);
      }

      // Sync subscription status
      await _syncSubscriptionStatus(userCredential.user!);

      return userCredential;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  // SIGN IN ANONYMOUSLY (GUEST MODE)
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();

      // Create minimal guest profile
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'isGuest': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw AuthException('Guest login failed: $e');
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    try {
      // If signed in with Google, sign out from Google as well
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  // PASSWORD RESET
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email.');
    }
  }

  // CONVERT GUEST TO PERMANENT ACCOUNT
  Future<void> convertGuestAccount(String email, String password) async {
    try {
      if (_auth.currentUser == null || !_auth.currentUser!.isAnonymous) {
        throw AuthException('No guest account to convert.');
      }

      // Create credentials
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link anonymous account with email/password
      final userCredential = await _auth.currentUser!.linkWithCredential(
        credential,
      );

      // Update user profile
      await _firestore.collection('users').doc(userCredential.user?.uid).update(
        {
          'email': email,
          'isGuest': false,
          'convertedAt': FieldValue.serverTimestamp(),
        },
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw AuthException(
          'This email is already in use. Please sign in instead.',
        );
      } else {
        throw AuthException(e.message ?? 'Failed to convert account.');
      }
    } catch (e) {
      throw AuthException('Account conversion failed: $e');
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in.');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete workout data
      await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              ds.reference.delete();
            }
          });

      // Delete user authentication
      await user.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: $e');
    }
  }

  // UPDATE USER PROFILE
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in.');
      }

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore profile
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }

  // Get user profile data
  Future<UserProfile> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return UserProfile.guest();
      }

      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await getDocumentWithRetry(docRef);

      if (!doc.exists) {
        // Create profile if it doesn't exist
        final newProfile = UserProfile(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          isGuest: user.isAnonymous,
        );

        await _createUserProfile(user);
        return newProfile;
      }

      return UserProfile.fromFirestore(doc);
    } catch (e) {
      throw AuthException('Failed to get user profile: $e');
    }
  }

  // HELPER METHODS
  Future<void> _createUserProfile(User user) async {
    final userProfile = {
      'id': user.uid,
      'email': user.email,
      'displayName':
          user.displayName ?? user.email?.split('@').first ?? 'Gym User',
      'photoURL': user.photoURL,
      'isGuest': user.isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isPremium': false, // Default to free tier
    };

    // Check if the profile already exists
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      // Update last login if profile exists
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new profile
      await _firestore.collection('users').doc(user.uid).set(userProfile);
    }
  }

  Future<DocumentSnapshot> getDocumentWithRetry(
    DocumentReference docRef, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await docRef.get();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 300 * attempts * attempts));
      }
    }
    throw Exception('Failed to get document after $maxRetries attempts');
  }

  Future<void> _updateLastLogin(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _syncSubscriptionStatus(User user) async {
    try {
      // Get stored premium status from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final localIsPremium = prefs.getBool('is_premium') ?? false;

      // Get user document
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final cloudIsPremium = doc.data()?['isPremium'] ?? false;

        if (localIsPremium && !cloudIsPremium) {
          // Update cloud with local premium status
          await _firestore.collection('users').doc(user.uid).update({
            'isPremium': true,
            'premiumUpdatedAt': FieldValue.serverTimestamp(),
          });
        } else if (!localIsPremium && cloudIsPremium) {
          // Update local with cloud premium status
          await prefs.setBool('is_premium', true);
        }
      }
    } catch (e) {
      // Non-fatal error, so just log it rather than throwing
    }
  }
}

// Custom exception class for auth errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
