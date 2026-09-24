import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Infos de mise à jour lues depuis Firestore (app_versions/{packageName}),
/// alimenté automatiquement par le workflow GitHub Actions à chaque build.
class UpdateInfo {
  final int latestVersionCode;
  final String latestVersionName;
  final String downloadUrl;
  final int sizeBytes;
  final bool forceUpdate;
  final String? message;

  const UpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.forceUpdate,
    this.message,
  });

  factory UpdateInfo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UpdateInfo(
      latestVersionCode: (data['latestVersionCode'] as num?)?.toInt() ?? 0,
      latestVersionName: data['latestVersionName']?.toString() ?? '',
      downloadUrl: data['downloadUrl']?.toString() ?? '',
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
      forceUpdate: data['forceUpdate'] as bool? ?? false,
      message: data['message']?.toString(),
    );
  }
}

class VersionService {
  final _versions = FirebaseFirestore.instance.collection('app_versions');

  /// Retourne les infos de mise à jour si une version plus récente existe,
  /// sinon null (app déjà à jour). Le nom du package Android sert d'ID de
  /// document, alimenté automatiquement par le workflow GitHub Actions.
  Future<UpdateInfo?> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

    final doc = await _versions.doc(packageInfo.packageName).get();
    if (!doc.exists) return null;

    final info = UpdateInfo.fromDoc(doc);
    if (info.latestVersionCode <= currentVersionCode) return null;

    final prefs = await SharedPreferences.getInstance();
    final snoozedVersionCode = prefs.getInt('update_snoozed_version_code');
    final snoozedUntilMillis = prefs.getInt('update_snoozed_until');

    if (snoozedVersionCode == info.latestVersionCode &&
        snoozedUntilMillis != null &&
        DateTime.now().millisecondsSinceEpoch < snoozedUntilMillis) {
      return null;
    }

    return info;
  }

  /// Enregistre un rappel de 24h pour une version donnée : le prompt de
  /// mise à jour ne réapparaîtra pas avant ce délai, sauf si une version
  /// plus récente sort entre-temps.
  Future<void> snoozeUpdate(int versionCode) async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    await prefs.setInt('update_snoozed_version_code', versionCode);
    await prefs.setInt('update_snoozed_until', until);
  }
}
