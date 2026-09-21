import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../services/submissions.dart';
import '../widgets/payment_status_dialog.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

/// Utilisé comme onglet « Don » (sans flèche retour) ou poussé depuis un projet
/// avec [project] présélectionné (flèche retour automatique).
class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key, this.project, this.onGoTo});
  final Project? project;
  final void Function(int)? onGoTo;

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  static const _quickAmounts = [5000, 10000, 20000, 50000, 100000];

  static const _payments = <String, List<String>>{
    'mobile_money': ['Mobile Money', 'Orange Money, M-Pesa, Airtel Money'],
    'other': ['Autre moyen', 'Nous vous contacterons pour convenir ensemble'],
  };

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  int? _quick;
  bool _other = false;
  late String _project = widget.project?.id ?? 'general';
  String _payment = 'mobile_money';
  bool _loading = false;

  @override
  void dispose() {
    _amount.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _pickQuick(int a) {
    setState(() {
      _quick = a;
      _other = false;
      _amount.text = a.toString();
    });
  }

  void _pickOther() {
    setState(() {
      _quick = null;
      _other = true;
      _amount.clear();
    });
  }

  void _onAmountChanged(String v) {
    final n = int.tryParse(v);
    setState(() {
      _quick = _quickAmounts.contains(n) ? n : null;
      _other = _quick == null && v.isNotEmpty;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_payment == 'mobile_money') {
      final amount = int.parse(_amount.text);
      final phone = _phone.text.trim();
      final donorName = _name.text.trim();
      final project = _project;
      _amount.clear();
      _name.clear();
      _phone.clear();
      setState(() {
        _quick = null;
        _other = false;
      });
      await showPaymentStatusDialog(
        context,
        amount: amount,
        phone: phone,
        donorName: donorName,
        project: project,
        onGoHome: () {
          if (widget.onGoTo != null) {
            widget.onGoTo!(AppTab.home);
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await SubmissionService.submitDonation({
        'amount': int.parse(_amount.text),
        'project': _project,
        'paymentMethod': _payment,
        'donorName': _name.text.trim(),
        'donorPhone': _phone.text.trim(),
      });
      if (!mounted) return;
      showAppSnack(context, 'Merci pour votre générosité ! Nous vous contacterons pour finaliser votre don.');
      _amount.clear();
      _name.clear();
      _phone.clear();
      setState(() {
        _quick = null;
        _other = false;
      });
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Une erreur est survenue. Merci de réessayer dans un instant.', error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faire un don')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHero(eyebrow: 'Soutenir notre mission', subtitle: 'Votre contribution peut changer une vie.'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  FormCard(
                    title: 'Choisissez un montant',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final a in _quickAmounts)
                            AppChoice(label: formatFc(a), selected: _quick == a, onTap: () => _pickQuick(a)),
                          AppChoice(label: 'Autre', selected: _other, onTap: _pickOther),
                        ],
                      ),
                      const Gap(14),
                      TextFormField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: _onAmountChanged,
                        decoration: inputDecoration('Montant (FC)', hint: 'Ex : 50000'),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 500) return 'Montant minimum : 500 FC';
                          return null;
                        },
                      ),
                      const Gap(18),
                      const Text('Projet à soutenir', style: AppText.h3),
                      const Gap(10),
                      if (widget.project != null)
                        SelectableTile(
                          title: widget.project!.title,
                          selected: _project == widget.project!.id,
                          onTap: () => setState(() => _project = widget.project!.id),
                        ),
                      for (final e in DemoData.donationTargets.entries)
                        SelectableTile(
                          title: e.value,
                          selected: _project == e.key,
                          onTap: () => setState(() => _project = e.key),
                        ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.vertClair,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Votre don servira à soutenir nos projets : orphelins, veuves, personnes âgées, aide alimentaire, etc.',
                          style: AppText.small,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  FormCard(
                    title: 'Moyen de paiement',
                    children: [
                      for (final e in _payments.entries)
                        SelectableTile(
                          title: e.value[0],
                          subtitle: e.value[1],
                          selected: _payment == e.key,
                          onTap: () => setState(() => _payment = e.key),
                        ),
                      const Gap(8),
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        validator: requiredValidator,
                        decoration: inputDecoration('Nom complet'),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: requiredValidator,
                        decoration: inputDecoration('Téléphone'),
                      ),
                      const Gap(18),
                      LoadingButton(label: 'Faire un don maintenant', loading: _loading, onPressed: _submit),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
