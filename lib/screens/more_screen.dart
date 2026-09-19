import 'package:flutter/material.dart';

import '../data/app_info.dart';
import '../navigation.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/contact_tiles.dart';

/// Onglet « Plus » : menu des pages secondaires + toutes les données de l'ancien footer
/// (marque/slogan, coordonnées, réseaux sociaux, copyright).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Marque (ex-footer-brand)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const LogoMark(size: 42),
                  const SizedBox(width: 12),
                  Expanded(child: Text(AppInfo.name, style: AppText.h2)),
                ]),
                const Gap(12),
                const Text('« ${AppInfo.slogan} »',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.vert)),
                const Gap(6),
                const Text(AppInfo.tagline, style: AppText.body),
              ],
            ),
          ),

          // Pages secondaires (ex-colonnes Navigation + Faire la différence)
          const _GroupTitle('Découvrir'),
          _MenuTile(icon: Icons.info_outline, label: 'Qui sommes-nous', onTap: () => openAbout(context)),
          _MenuTile(icon: Icons.volunteer_activism_outlined, label: 'Nos actions', onTap: () => openActions(context)),
          _MenuTile(icon: Icons.photo_library_outlined, label: 'Galerie', onTap: () => openGallery(context)),

          const _GroupTitle('Faire la différence'),
          _MenuTile(icon: Icons.favorite_border, label: 'Devenir bénévole', onTap: () => openVolunteer(context)),
          _MenuTile(icon: Icons.mail_outline, label: 'Nous écrire', onTap: () => openContact(context)),

          // Coordonnées (ex-colonne Nous contacter)
          const _GroupTitle('Nous contacter'),
          const ContactTiles(),

          // Réseaux sociaux
          const _GroupTitle('Suivez-nous'),
          const SocialRow(),

          // Copyright (ex-footer-bottom)
          const Gap(32),
          Center(
            child: Text(
              "© ${DateTime.now().year} ${AppInfo.name}\nTous droits réservés.",
              textAlign: TextAlign.center,
              style: AppText.small,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(text.toUpperCase(), style: AppText.eyebrow),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.vert),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: AppColors.texteSecondaire),
            ],
          ),
        ),
      ),
    );
  }
}
