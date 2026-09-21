import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Suppression du compte (exigée par Google Play).
/// Firebase refuse de supprimer un compte si la connexion est ancienne
/// (requires-recent-login) : on ré-authentifie donc d'abord l'utilisateur.
class AccountDeletion {
  static bool get usesPassword =>
      FirebaseAuth.instance.currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

  static Future<void> run({String? password}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final google = GoogleSignIn();

    // 1. Ré-authentification
    if (usesPassword) {
      final email = user.email;
      if (email == null || password == null || password.isEmpty) {
        throw FirebaseAuthException(code: 'wrong-password');
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } else {
      final account = await google.signIn();
      if (account == null) throw FirebaseAuthException(code: 'cancelled');
      final tokens = await account.authentication;
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(accessToken: tokens.accessToken, idToken: tokens.idToken),
      );
    }

    // 2. Profil (photo base64 comprise), tant que l'utilisateur est encore connecté.
    //    Si les règles Firestore refusent, rien n'est supprimé.
    await FirebaseFirestore.instance.collection('members').doc(user.uid).delete();

    // 3. Compte de connexion
    await user.delete();
    try {
      await google.signOut();
    } catch (_) {}
  }
}
