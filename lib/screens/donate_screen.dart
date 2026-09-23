import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/firestore_repo.dart';
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
  static const _mobileMoneyMinimum = 500;

  static const _payments = <String, List<String>>{
    'mobile_money': ['Mobile Money', 'Orange Money, M-Pesa, Airtel Money'],
    'other': ['Autre moyen', 'Nous vous contacterons pour convenir ensemble'],
  };

  static const _networks = <String, String>{
    'airtel_cd': 'Airtel Money',
    'orange_cd': 'Orange Money',
    'vodacom_cd': 'M-Pesa (Vodacom)',
  };

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  int? _quick;
  bool _other = false;
  late String _projectId = widget.project?.id ?? 'general';
  late String _projectTitle = widget.project?.title ?? 'Là où le besoin est le plus urgent';
  String _payment = 'mobile_money';
  String? _network;
  bool _loading = false;
  String? _networkError;

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

  void _selectProject(String id, String title) {
    setState(() {
      _projectId = id;
      _projectTitle = title;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_payment == 'mobile_money') {
      if (_network == null) {
        setState(() => _networkError = 'Choisissez votre opérateur.');
        return;
      }
      setState(() => _networkError = null);

      final amount = int.parse(_amount.text);
      final phone = _phone.text.trim();
      final donorName = _name.text.trim();
      final project = _projectId;
      final projectTitle = _projectTitle;
      final network = _network!;
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
        projectTitle: projectTitle,
        network: network,
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
        'project': _projectId,
        'projectTitle': _projectTitle,
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
                          final min = _payment == 'mobile_money' ? _mobileMoneyMinimum : 500;
                          if (n == null || n < min) return 'Montant minimum : ${formatFc(min)}';
                          return null;
                        },
                      ),
                      const Gap(18),
                      const Text('Projet à soutenir', style: AppText.h3),
                      const Gap(10),
                      SelectableTile(
                        title: 'Là où le besoin est le plus urgent',
                        selected: _projectId == 'general',
                        onTap: () => _selectProject('general', 'Là où le besoin est le plus urgent'),
                      ),
                      StreamBuilder<List<Project>>(
                        stream: FirestoreRepo.watchProjects(),
                        builder: (context, snap) {
                          final projects = snap.data ?? const <Project>[];
                          if (projects.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: [
                              for (final p in projects)
                                SelectableTile(
                                  title: p.title,
                                  selected: _projectId == p.id,
                                  onTap: () => _selectProject(p.id, p.title),
                                ),
                            ],
                          );
                        },
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
                      if (_payment == 'mobile_money') ...[
                        const Gap(14),
                        const Text('Choisissez votre opérateur', style: AppText.h3),
                        const Gap(10),
                        for (final e in _networks.entries)
                          SelectableTile(
                            title: e.value,
                            selected: _network == e.key,
                            onTap: () => setState(() {
                              _network = e.key;
                              _networkError = null;
                            }),
                          ),
                        if (_networkError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_networkError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ),
                      ],
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
