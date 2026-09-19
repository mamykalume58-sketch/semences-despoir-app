import 'package:flutter/material.dart';

class SocialLink {
  const SocialLink(this.label, this.icon, [this.url]);
  final String label;
  final IconData icon;

  /// null = lien pas encore renseigné (les liens du footer web étaient des "#").
  final String? url;
}

/// Toutes les données qui étaient dans le footer du site web, centralisées ici.
/// Affichées dans l'onglet « Plus » (voir screens/more_screen.dart) et dans l'écran Contact.
class AppInfo {
  AppInfo._();

  static const name = "Les Semences d'Espoir";
  static const slogan = "L'amour se partage, l'espoir se sème";
  static const tagline = 'Un groupe humanitaire au service des personnes vulnérables de Lubumbashi.';

  static const phone = '+243000000000';
  static const phoneDisplay = '+243 00 000 0000';
  static const whatsappNumber = '243000000000';
  static const email = 'contact@semencesdespoir.org';
  static const address = 'Lubumbashi, Haut-Katanga, RDC';

  static const socials = <SocialLink>[
    SocialLink('Facebook', Icons.facebook),
    SocialLink('WhatsApp', Icons.chat_bubble_outline, 'https://wa.me/$whatsappNumber'),
    SocialLink('Instagram', Icons.camera_alt_outlined),
    SocialLink('TikTok', Icons.music_note_outlined),
    SocialLink('YouTube', Icons.play_circle_outline),
  ];
}
