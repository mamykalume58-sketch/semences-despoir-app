import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';

enum _PayState { waiting, success, failed, serverError }

/// Popup non-fermable qui écoute donations/{donationId} en temps réel
/// et affiche le résultat du paiement une fois le statut connu.
Future<void> showPaymentStatusDialog(
  BuildContext context, {
  required String donationId,
  required VoidCallback onGoHome,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PaymentStatusDialog(donationId: donationId, onGoHome: onGoHome),
  );
}

class PaymentStatusDialog extends StatefulWidget {
  const PaymentStatusDialog({super.key, required this.donationId, required this.onGoHome});
  final String donationId;
  final VoidCallback onGoHome;

  @override
  State<PaymentStatusDialog> createState() => _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends State<PaymentStatusDialog> {
  _PayState _state = _PayState.waiting;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    _sub = FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donationId)
        .snapshots()
        .listen(
      (snap) {
        if (!mounted) return;
        final status = snap.data()?['status'] as String?;
        if (status == 'confirme') {
          setState(() => _state = _PayState.success);
        } else if (status == 'echoue') {
          setState(() => _state = _PayState.failed);
        }
        // sinon (pending) : on continue d'attendre
      },
      onError: (_) {
        if (mounted) setState(() => _state = _PayState.serverError);
      },
    );
    // Si rien n'a bougé après 90s, on considère que ça n'a pas abouti.
    _timeout = Timer(const Duration(seconds: 90), () {
      if (mounted && _state == _PayState.waiting) {
        setState(() => _state = _PayState.failed);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(28), child: _content()),
      ),
    );
  }

  Widget _content() {
    switch (_state) {
      case _PayState.waiting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: AppColors.vert),
            Gap(20),
            Text(
              'Veuillez confirmer votre contribution sur votre téléphone...',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
          ],
        );
      case _PayState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.vert, size: 56),
            const Gap(16),
            const Text(
              'Votre contribution a été effectuée avec succès. Merci pour votre générosité !',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onGoHome();
                },
                child: const Text("Retour à l'accueil"),
              ),
            ),
          ],
        );
      case _PayState.failed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            const Gap(16),
            const Text(
              "Votre contribution n'a pas été effectuée. Veuillez vérifier votre compte et réessayer.",
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        );
      case _PayState.serverError:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 56),
            const Gap(16),
            const Text(
              "Le service est indisponible pour l'instant. Veuillez nous contacter ou réessayer plus tard.",
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        );
    }
  }
}
