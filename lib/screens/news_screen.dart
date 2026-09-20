import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/firestore_news.dart';
import '../data/models.dart';
import '../navigation.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static final _filters = <String, String>{'all': 'Toutes', ...DemoData.newsCategories};
  final Stream<List<NewsItem>> _stream = FirestoreNews.watchNews();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualités')),
      body: StreamBuilder<List<NewsItem>>(
        stream: _stream,
        builder: (context, snap) {
          // Repli sur les données de démo uniquement si Firestore est illisible (comme Projets).
          final fallback = snap.hasError;
          if (!fallback && !snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.vert));
          }
          final all = fallback ? DemoData.news : snap.data!;
          final items = all.where((n) => _filter == 'all' || n.category == _filter).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const PageHero(eyebrow: 'Suivez-nous', subtitle: 'Restez informé de nos actions, projets et événements.'),
              if (fallback)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFC107),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Données de démonstration : lecture de Firestore impossible pour le moment.',
                    style: AppText.small,
                  ),
                ),
              FilterBar(options: _filters, selected: _filter, onChanged: (v) => setState(() => _filter = v)),
              const Gap(16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Aucune actualité publiée pour le moment.', style: AppText.body)),
                ),
              for (final n in items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GestureDetector(
                    onTap: () => openNews(context, n),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppImage(url: n.imageUrl, label: n.title, aspectRatio: 16 / 9, radius: 0),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.vertClair,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        DemoData.newsCategories[n.category] ?? n.category,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.vert,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(child: Text(formatDateFr(n.date), style: AppText.small)),
                                  ],
                                ),
                                const Gap(10),
                                Text(n.title, style: AppText.h3),
                                const Gap(6),
                                Text(n.summary, style: AppText.body),
                                const Gap(10),
                                const Text(
                                  'Lire la suite →',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.vert),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
