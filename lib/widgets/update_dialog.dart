import 'package:flutter/material.dart';

import '../data/app_info.dart';
import '../services/update_download_service.dart';
import '../services/version_service.dart';
import '../theme.dart';

/// Affiche le bottom sheet de mise à jour et gère le téléchargement +
/// l'installation directement depuis l'app.
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateInfo info,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: !info.forceUpdate,
    enableDrag: !info.forceUpdate,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UpdateSheet(info: info),
  );
}

class _UpdateSheet extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateSheet({required this.info});

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  final _downloadService = UpdateDownloadService();
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      final file = await _downloadService.downloadApk(
        widget.info.downloadUrl,
        onProgress: (p) => setState(() => _progress = p),
      );
      await _downloadService.installApk(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = 'Échec du téléchargement. Réessayez dans un instant.';
      });
    }
  }

  String get _sizeLabel {
    final mb = widget.info.sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} Mo';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.info.forceUpdate,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.vertClair,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update_rounded, color: AppColors.vert, size: 44),
            ),
            const Gap(20),
            Text('Mettre à jour ${AppInfo.name}', textAlign: TextAlign.center, style: AppText.h3),
            const Gap(6),
            Text(
              'Version ${widget.info.latestVersionName} • $_sizeLabel',
              style: AppText.small,
            ),
            const Gap(16),
            Text(
              widget.info.message?.isNotEmpty == true
                  ? widget.info.message!
                  : 'Une nouvelle version de l\'app est disponible. Vous pouvez la télécharger maintenant.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            if (_error != null) ...[
              const Gap(12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
            const Gap(24),
            if (_downloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: AppColors.vertClair,
                  color: AppColors.vert,
                ),
              ),
              const Gap(8),
              Text('${(_progress * 100).toStringAsFixed(0)} %', style: AppText.small),
              const Gap(16),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _startDownload,
                  child: const Text('Télécharger maintenant'),
                ),
              ),
            if (!widget.info.forceUpdate && !_downloading) ...[
              const Gap(10),
              TextButton(
                onPressed: () async {
                  await VersionService().snoozeUpdate(widget.info.latestVersionCode);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Me le rappeler plus tard'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
