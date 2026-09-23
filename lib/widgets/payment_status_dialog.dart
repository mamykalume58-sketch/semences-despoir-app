import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/payment_service.dart';
import '../theme.dart';
import 'common.dart';

enum _PayState { initiating, needsRedirect, waiting, success, failed, serverError }

/// Popup non-fermable qui lance elle-même le paiement Mobile Money,
/// puis sonde régulièrement le statut réel auprès du Worker (SasPay)
/// jusqu'à confirmation, échec, ou expiration du délai.
Future<void> showPaymentStatusDialog(
  BuildContext context, {
  required int amount,
  required String phone,
  required String donorName,
  required String project,
  required String network,
  String? projectTitle,
  required VoidCallback onGoHome,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PaymentStatusDialog(
      amount: amount,
      phone: phone,
      donorName: donorName,
      project: project,
      network: network,
      projectTitle: projectTitle,
      onGoHome: onGoHome,
    ),
  );
}

class PaymentStatusDialog extends StatefulWidget {
  const PaymentStatusDialog({
    super.key,
    required this.amount,
    required this.phone,
    required this.donorName,
    required this.project,
    required this.network,
    this.projectTitle,
    required this.onGoHome,
  });
  final int amount;
  final String phone;
  final String donorName;
  final String project;
  final String network;
  final String? projectTitle;
  final VoidCallback onGoHome;

  @override
  State<PaymentStatusDialog> createState() => _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends State<PaymentStatusDialog> {
  _PayState _state = _PayState.initiating;
  String? _donationId;
  String? _checkoutUrl;
  late final String _idempotencyKey = PaymentService.newIdempotencyKey();
  Timer? _poll;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final result = await PaymentService.payMobileMoney(
        amount: widget.amount,
        phone: widget.phone,
        donorName: widget.donorName,
        project: widget.project,
        projectTitle: widget.projectTitle,
        network: widget.network,
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      _donationId = result.id;
      if (result.checkoutUrl.isNotEmpty) {
        _checkoutUrl = result.checkoutUrl;
        setState(() => _state = _PayState.needsRedirect);
      } else {
        setState(() => _state = _PayState.waiting);
        _startPolling();
      }
    } catch (e) {
      debugPrint('Erreur initiation paiement Mobile Money : $e');
      if (mounted) setState(() => _state = _PayState.serverError);
    }
  }

  Future<void> _openCheckout() async {
    final url = _checkoutUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Si l'ouverture échoue, on laisse quand même le sondage démarrer :
      // le client a pu compléter le paiement autrement.
    }
    if (!mounted) return;
    setState(() => _state = _PayState.waiting);
    _startPolling();
  }

  void _startPolling() {
    _timeout = Timer(const Duration(seconds: 90), () {
      if (mounted && _state == _PayState.waiting) {
        setState(() => _state = _PayState.failed);
      }
    });
    _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_donationId == null) return;
      try {
        final status = await PaymentService.verifyStatus(_donationId!);
        if (!mounted) return;
        if (status == 'confirme') {
          _poll?.cancel();
          _timeout?.cancel();
          setState(() => _state = _PayState.success);
        } else if (status == 'echoue') {
          _poll?.cancel();
          _timeout?.cancel();
          setState(() => _state = _PayState.failed);
        }
        // sinon (pending) : on continue de sonder
      } catch (e) {
        debugPrint('Erreur vérification statut : $e');
        // Erreur ponctuelle réseau : on retente au prochain tick.
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
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
      case _PayState.initiating:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: AppColors.vert),
            Gap(20),
            Text('Initialisation du paiement...', textAlign: TextAlign.center, style: AppText.body),
          ],
        );
      case _PayState.needsRedirect:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new, color: AppColors.vert, size: 48),
            const Gap(16),
            const Text(
              'Une page de paiement va s\'ouvrir pour finaliser votre contribution.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _openCheckout,
                child: const Text('Continuer le paiement'),
              ),
            ),
          ],
        );
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
