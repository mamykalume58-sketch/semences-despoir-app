import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/account_deletion.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'common.dart';

class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key});

  Future<void> _confirm(BuildContext context) async {
    final usesPassword = AccountDeletion.usesPassword;
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre compte et votre profil (nom, téléphone, photo) seront supprimés définitivement. '
              'Les dons déjà enregistrés sont conservés pour le suivi comptable.',
            ),
            const SizedBox(height: 12),
            if (usesPassword)
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe pour confirmer'),
              )
            else
              const Text('Vous devrez vous reconnecter avec Google pour confirmer.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.erreur)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await AccountDeletion.run(password: controller.text);
      if (context.mounted) showAppSnack(context, 'Votre compte a été supprimé.');
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          showAppSnack(context, 'Mot de passe incorrect.', error: true);
          break;
        case 'cancelled':
          showAppSnack(context, 'Suppression annulée.');
          break;
        case 'user-mismatch':
          showAppSnack(context, 'Choisissez le compte Google utilisé pour cette inscription.', error: true);
          break;
        case 'requires-recent-login':
          showAppSnack(context, 'Reconnectez-vous puis réessayez.', error: true);
          break;
        case 'permission-denied':
          showAppSnack(context, 'Suppression refusée (règles Firestore). Rien n\'a été supprimé.', error: true);
          break;
        default:
          showAppSnack(context, 'Échec de la suppression (${e.code}).', error: true);
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnack(context, 'Échec de la suppression. Vérifiez votre connexion.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snap) {
        if (snap.data == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _confirm(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x55D93025)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.erreur),
                  SizedBox(width: 14),
                  Text(
                    'Supprimer mon compte',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.erreur),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
