import 'package:flutter/material.dart';

import '../data/app_info.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../data/firestore_repo.dart';
import '../data/firestore_actions.dart';
import '../data/firestore_settings.dart';
import '../navigation.dart';
import '../services/submissions.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/project_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoTo});
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const LogoMark(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppInfo.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.vertFonce),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _hero(context),
          _stats(),
          const SectionHead(
            eyebrow: 'Ce que nous faisons',
            title: "Nos actions en un coup d'œil",
            subtitle: 'Six domaines d\'intervention, une seule mission : redonner de la dignité et de l\'espoir.',
          ),
          StreamBuilder<List<ActionItem>>(
            stream: FirestoreActions.watchActions(),
            builder: (context, snapshot) {
              final latestByCategory = <String, String>{};
              for (final item in snapshot.data ?? const <ActionItem>[]) {
                if (item.imageUrl == null || item.imageUrl!.isEmpty) continue;
                latestByCategory.putIfAbsent(item.category, () => item.imageUrl!);
              }
              return Column(
                children: [
                  for (final a in DemoData.actions)
                    _ActionTile(area: a, imageUrl: latestByCategory[a.adminCategory]),
                ],
              );
            },
          ),
          _sloganBlock(),
          const SectionHead(eyebrow: 'Nos derniers projets', title: 'Des projets pour un impact durable'),
          StreamBuilder<List<Project>>(
            stream: FirestoreRepo.watchProjects(),
            builder: (context, snapshot) {
              final source = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : DemoData.projects;
              final featured = source.where((p) => p.status != ProjectStatus.aVenir).take(3).toList();
              return Column(
                children: [
                  for (final p in featured)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ProjectCard(project: p),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              label: 'Voir tous les projets',
              outlined: true,
              expand: true,
              onPressed: () => onGoTo(AppTab.projects),
            ),
          ),
          const Gap(28),
          const _NewsletterCard(),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.or, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Groupe humanitaire — Lubumbashi, RDC',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.vert),
                  ),
                ),
              ],
            ),
          ),
          const Gap(14),
          const Text(
            "Ensemble, semons l'espoir pour un avenir meilleur",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.vertFonce),
          ),
          const Gap(12),
          Text(
            "Vivre pour les Autres est un groupe humanitaire qui vient en aide aux personnes vulnérables et agit concrètement pour améliorer les conditions de vie dans les communautés.",
            style: AppText.body.copyWith(fontSize: 15),
          ),
          const Gap(18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(label: 'Nous soutenir', onPressed: () => onGoTo(AppTab.donate)),
              AppButton(label: 'Devenir bénévole', outlined: true, onPressed: () => openVolunteer(context)),
            ],
          ),
          const Gap(12),
          const Text('🌱 Chaque geste compte. Chaque vie compte.', style: AppText.small),
          const Gap(20),
          Stack(
            children: [
              StreamBuilder<SiteSettings>(
                stream: FirestoreSettings.watchSettings(),
                builder: (context, snapshot) {
                  return AppImage(
                    url: snapshot.data?.heroImage,
                    label: 'Photo : enfant plantant une pousse',
                    aspectRatio: 4 / 3,
                    radius: 24,
                  );
                },
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: const Text(
                    'Plus de 520 personnes accompagnées depuis notre création',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.vertFonce),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return StreamBuilder<List<Stat>>(
      stream: FirestoreStats.watchStats(),
      builder: (context, snapshot) {
        final s = (snapshot.hasData && snapshot.data!.isNotEmpty) ? snapshot.data! : DemoData.stats;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: _StatCard(s[0])),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(s[1])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(s[2])),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(s[3])),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _sloganBlock() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.vert, AppColors.vertFonce],
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.eco_outlined, color: AppColors.or, size: 34),
          SizedBox(height: 12),
          Text(
            "« L'amour se partage,\nl'espoir se sème »",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, height: 1.3, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            'Une graine à la fois, nous bâtissons des communautés plus fortes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xCCFFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.stat);
  final Stat stat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Column(
          children: [
            Text(stat.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.vert)),
            const SizedBox(height: 4),
            Text(stat.label, textAlign: TextAlign.center, style: AppText.small),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.area, this.imageUrl});
  final ActionArea area;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GestureDetector(
        onTap: () => openActions(context, category: area.id),
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? AppImage(url: imageUrl, label: area.title, radius: 12)
                      : Container(
                          decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(12)),
                          child: Icon(area.icon, color: AppColors.vert),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(area.title, style: AppText.h3),
                      const SizedBox(height: 2),
                      Text(area.description, style: AppText.small, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.texteSecondaire),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsletterCard extends StatefulWidget {
  const _NewsletterCard();

  @override
  State<_NewsletterCard> createState() => _NewsletterCardState();
}

class _NewsletterCardState extends State<_NewsletterCard> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await SubmissionService.subscribeNewsletter(_email.text.trim());
      if (!mounted) return;
      _email.clear();
      showAppSnack(context, 'Merci ! Vous serez informé de nos prochaines actions.');
    } catch (_) {
      if (mounted) showAppSnack(context, 'Une erreur est survenue. Merci de réessayer.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(24)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Restez informé de nos actions', style: AppText.h2),
            const SizedBox(height: 6),
            const Text('Recevez nos actualités et nos prochains projets par email.', style: AppText.body),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              decoration: inputDecoration('Votre adresse e-mail').copyWith(fillColor: Colors.white),
            ),
            const SizedBox(height: 12),
            LoadingButton(label: "S'abonner", loading: _loading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
