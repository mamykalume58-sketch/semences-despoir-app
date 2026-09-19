import 'package:flutter/material.dart';

import '../data/app_info.dart';
import '../theme.dart';
import 'common.dart';

/// Coordonnées (ex-colonne « Nous contacter » du footer web) :
/// téléphone, WhatsApp, e-mail, localisation. Utilisé dans l'onglet Plus et l'écran Contact.
class ContactTiles extends StatelessWidget {
  const ContactTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContactTile(
          icon: Icons.phone_outlined,
          label: 'Téléphone',
          value: AppInfo.phoneDisplay,
          onTap: () => openLink(context, 'tel:${AppInfo.phone}'),
        ),
        _ContactTile(
          icon: Icons.chat_bubble_outline,
          label: 'WhatsApp',
          value: 'Ouvrir la conversation',
          onTap: () => openLink(context, 'https://wa.me/${AppInfo.whatsappNumber}'),
        ),
        _ContactTile(
          icon: Icons.mail_outline,
          label: 'Email',
          value: AppInfo.email,
          onTap: () => openLink(context, 'mailto:${AppInfo.email}'),
        ),
        _ContactTile(
          icon: Icons.place_outlined,
          label: 'Localisation',
          value: AppInfo.address,
          onTap: () => openLink(
            context,
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(AppInfo.address)}',
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.vert, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppText.small),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texte),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icônes des réseaux sociaux (ex-« social-row » du footer web).
class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final s in AppInfo.socials)
          Tooltip(
            message: s.label,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => openLink(context, s.url),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.vertClair, shape: BoxShape.circle),
                child: Icon(s.icon, color: AppColors.vert, size: 22),
              ),
            ),
          ),
      ],
    );
  }
}
