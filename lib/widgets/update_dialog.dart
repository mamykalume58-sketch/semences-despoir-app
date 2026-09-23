import 'package:flutter/material.dart';

import '../services/version_service.dart';
import '../theme.dart';

/// Affiche le dialogue de mise à jour si [info] est non-null.
/// Non-fermable par retour/tap-extérieur si [info.forceUpdate] est vrai.
Future<void> showUpdateDialog(BuildContext context, UpdateInfo info) {
  return showDialog(
    context: context,
    barrierDismissible: !info.forceUpdate,
    builder: (_) => PopScope(
      canPop: !info.forceUpdate,
      child: UpdateDialog(info: info),
    ),
  );
}

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key, required this.info});
  final UpdateInfo info;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final _service = VersionService();
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  String get _sizeLabel {
    final mb = widget.info.sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} Mo';
  }

  Future<void> _update() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      await _service.downloadAndInstall(
        widget.info,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = "$e";
        });
      }
    }
  }

  void _later() {
    _service.snoozeUpdate(widget.info.latestVersionCode);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle version disponible'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${widget.info.latestVersionName} · $_sizeLabel',
            style: const TextStyle(color: Colors.black54),
          ),
          if (widget.info.message != null && widget.info.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(widget.info.message!),
          ],
          if (_downloading) ...[
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              color: AppColors.vert,
            ),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toStringAsFixed(0)} %'),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
      actions: [
        if (!widget.info.forceUpdate && !_downloading)
          TextButton(onPressed: _later, child: const Text('Plus tard')),
        FilledButton(
          onPressed: _downloading ? null : _update,
          child: Text(_downloading ? 'Téléchargement...' : 'Mettre à jour'),
        ),
      ],
    );
  }
}
