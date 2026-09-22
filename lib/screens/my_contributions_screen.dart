import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/firestore_repo.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../navigation.dart';

const _statusLabels = <String, String>{
  'pending': 'En attente',
  'completed': 'Confirmé',
  'failed': 'Échoué',
  'cancelled': 'Annulé',
};

Color _statusColor(String status) {
  switch (status) {
    case 'completed':
      return AppColors.vert;
    case 'failed':
    case 'cancelled':
      return AppColors.erreur;
    default:
      return AppColors.or;
  }
}

class MyContributionsScreen extends StatelessWidget {
  const MyContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes contributions')),
      body: user == null ? _LoggedOutView() : _ContributionsList(uid: user.uid),
    );
  }
}

class _LoggedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: AppColors.texteSecondaire),
            const Gap(16),
            const Text(
              'Connectez-vous pour voir l\'historique de vos contributions.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const Gap(20),
            AppButton(label: 'Se connecter', onPressed: () => openLogin(context)),
          ],
        ),
      ),
    );
  }
}

class _ContributionsList extends StatelessWidget {
  const _ContributionsList({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreRepo.watchMyDonations(uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.vert));
        }
        final donations = snap.data!;
        if (donations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 56, color: AppColors.texteSecondaire),
                  const Gap(16),
                  const Text(
                    'Vous n\'avez pas encore contribué.\nDécouvrez nos projets et faites la différence !',
                    textAlign: TextAlign.center,
                    style: AppText.body,
                  ),
                  const Gap(20),
                  AppButton(label: 'Faire un don', onPressed: () => openDonate(context)),
                ],
              ),
            ),
          );
        }

        final totalConfirme = donations
            .where((d) => d['status'] == 'completed')
            .fold<int>(0, (sum, d) => sum + ((d['amount'] as num?)?.toInt() ?? 0));

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total de vos contributions confirmées', style: AppText.eyebrow),
                    const Gap(6),
                    Text(formatFc(totalConfirme), style: AppText.h1),
                  ],
                ),
              ),
            ),
            const Gap(16),
            for (final d in donations) _ContributionTile(donation: d),
          ],
        );
      },
    );
  }
}

class _ContributionTile extends StatelessWidget {
  const _ContributionTile({required this.donation});
  final Map<String, dynamic> donation;

  @override
  Widget build(BuildContext context) {
    final status = (donation['status'] ?? 'pending') as String;
    final amount = (donation['amount'] as num?)?.toInt() ?? 0;
    final projectTitle = (donation['projectTitle'] ?? 'Don général') as String;
    final createdAt = donation['createdAt'];
    final date = createdAt is Timestamp ? createdAt.toDate() : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(projectTitle, style: AppText.h3),
                    const SizedBox(height: 4),
                    Text(date != null ? formatDateFr(date) : '—', style: AppText.small),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatFc(amount), style: AppText.h3),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusLabels[status] ?? status,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _statusColor(status)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
