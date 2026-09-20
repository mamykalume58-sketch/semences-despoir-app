import 'package:cloud_firestore/cloud_firestore.dart';

/// Document `settings/general` (admin : src/pages/settings/SettingsPage.jsx) :
/// siteName, slogan, phone, whatsapp, email, address, facebook, instagram,
/// tiktok, youtube, heroImage (base64), aboutImage (base64), updatedAt.
class SiteSettings {
  const SiteSettings({this.heroImage, this.aboutImage});

  final String? heroImage;
  final String? aboutImage;

  factory SiteSettings.fromMap(Map<String, dynamic> d) {
    String? img(String k) {
      final v = (d[k] ?? '').toString();
      return v.isEmpty ? null : v;
    }
    return SiteSettings(heroImage: img('heroImage'), aboutImage: img('aboutImage'));
  }
}

class FirestoreSettings {
  static final _db = FirebaseFirestore.instance;

  static Stream<SiteSettings> watchSettings() {
    return _db.collection('settings').doc('general').snapshots().map((snap) {
      final d = snap.data();
      return d == null ? const SiteSettings() : SiteSettings.fromMap(d);
    });
  }
}
