import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// REGISTER DENGAN USERNAME, EMAIL, PASSWORD
  Future<User?> register(String email, String password, String username) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCred.user;

    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "username": username,
        "email": email,
        "role": "user",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  /// LOGIN EMAIL + PASSWORD
  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// GOOGLE SIGN IN
  Future<User?> signInWithGoogle() async {
    // 1. Trigger Google Sign In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled

    // 2. Obtain details from request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3. Create credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to Firebase
    final UserCredential userCred = await _auth.signInWithCredential(
      credential,
    );
    final User? user = userCred.user;

    if (user != null) {
      // 5. Check if user doc exists
      final userDoc = await _db.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create new user doc
        await _db.collection('users').doc(user.uid).set({
          "uid": user.uid,
          "username": user.displayName ?? "User Google",
          "email": user.email,
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
          "photoUrl": user.photoURL,
        });
      }
    }

    return user;
  }
}
