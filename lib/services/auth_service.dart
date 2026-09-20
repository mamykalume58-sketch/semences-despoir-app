import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _google = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null; // annulé par l'utilisateur
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  static Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
