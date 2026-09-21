import 'package:flutter/material.dart';

import '../data/models.dart';
import '../navigation.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/project_card.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Scaffold(
      appBar: AppBar(title: const Text('Projet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(children: [
            Flexible(child: Text(p.category.toUpperCase(), style: AppText.eyebrow)),
            const SizedBox(width: 10),
            StatusTag(p.status),
          ]),
          const Gap(8),
          Text(p.title, style: AppText.h1),
          const Gap(8),
          Text(p.summary, style: AppText.body),
          const Gap(16),
          AppImage(url: p.imageUrl, label: 'Photo principale du projet', aspectRatio: 16 / 9, radius: 20),
          const Gap(16),
          _FundingCard(project: p),
          if (p.description != null) ...[
            const _Title('Description'),
            Text(p.description!, style: AppText.body),
          ],
          if (p.objectives.isNotEmpty) ...[
            const _Title('Objectifs'),
            for (final o in p.objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle, size: 18, color: AppColors.vert),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(o, style: AppText.body)),
                  ],
                ),
              ),
          ],
          if (p.galleryCount > 0) ...[
            const _Title('Galerie'),
            Row(
              children: [
                for (var i = 0; i < p.galleryCount; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: AppImage(label: 'Photo ${i + 1}', aspectRatio: 1, radius: 14)),
                ],
              ],
            ),
          ],
          if (p.updates.isNotEmpty) ...[
            const _Title('Mises à jour'),
            for (final u in p.updates)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grisClair,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border(left: BorderSide(color: AppColors.vert, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.date, style: AppText.small.copyWith(fontWeight: FontWeight.w600, color: AppColors.vert)),
                    const SizedBox(height: 4),
                    Text(u.text, style: AppText.body),
                  ],
                ),
              ),
          ],
          if (p.transparency != null) ...[
            const _Title('Transparence'),
            Text(p.transparency!, style: AppText.body),
          ],
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(text, style: AppText.h2),
    );
  }
}

class _FundingCard extends StatelessWidget {
  const _FundingCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final goal = p.goal;
    final days = p.deadline?.difference(DateTime.now()).inDays;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: goal == null
            ? const Text("Objectif de collecte : à définir.", style: AppText.body)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatFc(p.collected),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.vert),
                  ),
                  Text('collectés sur ${formatFc(goal)}', style: AppText.small),
                  const Gap(14),
                  AppProgressBar(value: p.progress),
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.percentLabel, style: AppText.small),
                      if (days != null && days > 0 && p.status == ProjectStatus.enCours)
                        Text('$days jours restants', style: AppText.small),
                    ],
                  ),
                  if (p.status == ProjectStatus.enCours) ...[
                    const Gap(16),
                    AppButton(
                      label: 'Soutenir ce projet',
                      expand: true,
                      onPressed: () => openDonate(context, project: p),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
