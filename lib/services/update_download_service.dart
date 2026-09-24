import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

/// Télécharge l'APK depuis downloadUrl (asset public d'une GitHub Release)
/// et déclenche l'installation via l'intent système Android.
class UpdateDownloadService {
  Future<File> downloadApk(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);

    if (response.statusCode != 200) {
      throw Exception('Téléchargement échoué (HTTP ${response.statusCode})');
    }

    final total = response.contentLength ?? 0;
    var received = 0;
    final bytes = <int>[];

    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      received += chunk.length;
      if (total > 0) onProgress?.call(received / total);
    }

    if (total > 0 && received != total) {
      throw Exception('Fichier incomplet ($received/$total octets)');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/vpla_update.apk');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> installApk(File apkFile) async {
    final status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      await Permission.requestInstallPackages.request();
    }
    await OpenFilex.open(apkFile.path);
  }
}
