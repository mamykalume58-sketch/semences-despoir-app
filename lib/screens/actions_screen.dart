import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../navigation.dart';
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

  late String _filter = _filters.containsKey(widget.initialCategory) ? widget.initialCategory! : 'all';

  @override
  Widget build(BuildContext context) {
    final items = DemoData.actions.where((a) => _filter == 'all' || a.id == _filter).toList();
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
          for (final a in items)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppImage(label: a.title, aspectRatio: 16 / 9, radius: 0),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.vertClair,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(a.icon, color: AppColors.vert, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(a.title, style: AppText.h3)),
                            ],
                          ),
                          const Gap(10),
                          Text(a.description, style: AppText.body),
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.vertClair,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${a.count} actions réalisées',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.vert),
                            ),
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: () => openContact(context),
                            child: const Text(
                              'En savoir plus →',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.vert),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
