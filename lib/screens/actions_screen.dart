import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/firestore_actions.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ActionsScreen extends StatefulWidget {
  const ActionsScreen({super.key, this.initialCategory});
  final String? initialCategory;

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  static final _filters = <String, String>{
    'all': 'Toutes',
    for (final a in DemoData.actions) a.id: a.title,
  };

  final Stream<List<ActionItem>> _stream = FirestoreActions.watchActions();
  late String _filter = _filters.containsKey(widget.initialCategory) ? widget.initialCategory! : 'all';

  /// Catégorie Firestore (« Personnes âgées », « Autres »...) <-> domaine de l'app.
  bool _inArea(ActionItem a, ActionArea area) {
    final c = a.category.trim().toLowerCase();
    final t = area.title.trim().toLowerCase();
    return c == t || (t.startsWith('autres') && c == 'autres');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nos actions')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHero(
            eyebrow: 'Sur le terrain',
            subtitle: "Des gestes concrets pour un meilleur demain, dans six domaines d'intervention.",
          ),
          FilterBar(options: _filters, selected: _filter, onChanged: (v) => setState(() => _filter = v)),
          const Gap(16),
          StreamBuilder<List<ActionItem>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                debugPrint('Lecture actions : ${snap.error}');
                return const _Message('Impossible de charger les actions pour le moment. Vérifiez votre connexion et réessayez.');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.vert)),
                );
              }
              final area = _filter == 'all' ? null : DemoData.actions.firstWhere((x) => x.id == _filter);
              final items = snap.data!.where((a) => area == null || _inArea(a, area)).toList();
              if (items.isEmpty) return const _Message('Aucune action publiée pour le moment.');
              return Column(
                children: [for (final a in items) _ActionCard(action: a)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: Text(text, textAlign: TextAlign.center, style: AppText.body)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final ActionItem action;

  Widget _meta(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.vert),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppText.small)),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = action;
    final when = a.whenLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(url: a.imageUrl, label: a.title, aspectRatio: 16 / 9, radius: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (a.category.isNotEmpty) _pill(a.category, AppColors.vertClair, AppColors.vert),
                      if (a.statusLabel.isNotEmpty) _pill(a.statusLabel, AppColors.or, AppColors.vertFonce),
                    ],
                  ),
                  const Gap(10),
                  Text(a.title, style: AppText.h3),
                  if (a.description.isNotEmpty) ...[
                    const Gap(6),
                    Text(a.description, style: AppText.body),
                  ],
                  const Gap(6),
                  if (when != null) _meta(Icons.event_outlined, when),
                  if (a.location != null) _meta(Icons.place_outlined, a.location!),
                  if (a.beneficiaires > 0) _meta(Icons.groups_outlined, '${a.beneficiaires} bénéficiaires'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
