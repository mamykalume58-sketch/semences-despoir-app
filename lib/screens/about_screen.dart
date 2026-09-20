import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../data/firestore_settings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _values = <List<String>>[
    ['🤝', 'Solidarité'],
    ['❤️', 'Humanité'],
    ['✅', 'Intégrité'],
    ['🌱', 'Engagement'],
    ['🕊️', 'Espoir'],
    ['🔍', 'Transparence'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qui sommes-nous')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const PageHero(
            eyebrow: 'Une petite graine, de grands changements',
            subtitle: 'Découvrez notre histoire, notre mission et les valeurs qui nous animent.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NOTRE HISTOIRE', style: AppText.eyebrow),
                const Gap(6),
                const Text("Née d'une conviction simple", style: AppText.h2),
                const Gap(10),
                const Text(
                  "Vivre pour les Autres est née d'une volonté d'apporter de l'aide et de l'amour aux plus vulnérables. Face à la souffrance et aux inégalités, un groupe de bénévoles a décidé d'agir, ensemble, pour semer l'espoir dans nos communautés.",
                  style: AppText.body,
                ),
                const Gap(10),
                const Text(
                  "Depuis, chaque action, chaque don et chaque visite s'inscrit dans cette même conviction : personne ne devrait être laissé pour compte.",
                  style: AppText.body,
                ),
                const Gap(16),
                StreamBuilder<SiteSettings>(
                  stream: FirestoreSettings.watchSettings(),
                  builder: (context, snapshot) {
                    return AppImage(
                      url: snapshot.data?.aboutImage,
                      label: "Photo : l'équipe sur le terrain",
                      aspectRatio: 16 / 9,
                      radius: 20,
                    );
                  },
                ),
                const Gap(24),
                const _InfoCard(
                  icon: Icons.flag_outlined,
                  title: 'Notre mission',
                  text: "Apporter de l'aide et du soutien aux personnes vulnérables et contribuer au développement de nos communautés.",
                ),
                const _InfoCard(
                  icon: Icons.visibility_outlined,
                  title: 'Notre vision',
                  text: 'Une société plus solidaire, où chaque personne vulnérable peut bénéficier d\'un soutien concret et durable.',
                ),
                const _InfoCard(
                  icon: Icons.diamond_outlined,
                  title: 'Nos valeurs',
                  text: 'Solidarité, humanité, intégrité, engagement, espoir et transparence guident chacune de nos actions.',
                ),
                const Gap(12),
                const Text('CE QUI NOUS PORTE', style: AppText.eyebrow),
                const Gap(6),
                const Text('Nos valeurs', style: AppText.h2),
                const Gap(14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [for (final v in _values) _ValueChip(emoji: v[0], label: v[1])],
                ),
                const Gap(28),
                const Text('Pourquoi nous choisir ?', style: AppText.h2),
                const Gap(14),
                const _InfoCard(
                  title: 'Une équipe engagée et passionnée',
                  text: 'Des bénévoles présents sur le terrain, au plus près des besoins réels.',
                ),
                const _InfoCard(
                  title: 'Une gestion transparente et responsable',
                  text: "Chaque don est suivi et son usage communiqué en toute clarté.",
                ),
                const _InfoCard(
                  title: 'Un impact concret sur le terrain',
                  text: 'Des résultats mesurables, visibles dans la vie des personnes aidées.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({this.icon, required this.title, required this.text});
  final IconData? icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: AppColors.vert),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(title, style: AppText.h3),
                const SizedBox(height: 6),
                Text(text, style: AppText.body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.vertFonce)),
        ],
      ),
    );
  }
}
