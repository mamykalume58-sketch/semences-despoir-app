import 'package:flutter/material.dart';

import '../data/models.dart';
import '../navigation.dart';
import '../theme.dart';
import '../utils.dart';
import 'common.dart';

class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg = Colors.white;
    switch (status) {
      case ProjectStatus.enCours:
        bg = AppColors.vert;
        break;
      case ProjectStatus.realise:
        bg = AppColors.vertFonce;
        break;
      case ProjectStatus.aVenir:
        bg = AppColors.or;
        fg = AppColors.vertFonce;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final goalText = p.goal == null ? 'Objectif : à définir' : '${formatFc(p.goal!)} visés';

    return GestureDetector(
      onTap: () => openProject(context, p),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppImage(url: p.imageUrl, label: p.title, aspectRatio: 16 / 9, radius: 0),
                Positioned(top: 12, left: 12, child: StatusTag(p.status)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: AppText.h3),
                  const Gap(6),
                  Text(p.summary, style: AppText.body),
                  const Gap(14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text(goalText, style: AppText.small)),
                      Text(
                        p.percentLabel,
                        style: AppText.small.copyWith(fontWeight: FontWeight.w600, color: AppColors.vert),
                      ),
                    ],
                  ),
                  const Gap(6),
                  AppProgressBar(value: p.progress),
                  const Gap(14),
                  _cta(context, p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cta(BuildContext context, Project p) {
    if (p.status == ProjectStatus.enCours) {
      return AppButton(
        label: 'Soutenir ce projet',
        small: true,
        onPressed: () => openDonate(context, project: p),
      );
    }
    if (p.status == ProjectStatus.realise) {
      return AppButton(label: 'Voir le bilan', small: true, onPressed: () => openProject(context, p));
    }
    return AppButton(label: 'Voir le projet', small: true, outlined: true, onPressed: () => openProject(context, p));
  }
}
