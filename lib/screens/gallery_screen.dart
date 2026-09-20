import 'package:flutter/material.dart';

import '../data/firestore_gallery.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final Stream<List<GalleryItem>> _stream = FirestoreGallery.watchGallery();
  String _filter = 'all';

  void _open(GalleryItem g) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AppImage(url: g.url, label: g.label, aspectRatio: 1, radius: 14),
                  if (g.isVideo) const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                ],
              ),
              const SizedBox(height: 12),
              Text(g.label, style: AppText.h3, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fermer')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(String text) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text(text, textAlign: TextAlign.center, style: AppText.body)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galerie')),
      body: Column(
        children: [
          const PageHero(eyebrow: 'En images', subtitle: 'Photos et vidéos de nos actions sur le terrain.'),
          Expanded(
            child: StreamBuilder<List<GalleryItem>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) return _message('Lecture de la galerie impossible.\n${snap.error}');
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.vert));
                }
                final all = snap.data!;
                if (all.isEmpty) return _message('Aucune photo pour le moment.');

                // Filtres construits à partir des catégories réellement présentes dans Firestore.
                final cats = <String>{for (final g in all) if (g.category.isNotEmpty) g.category};
                final filters = <String, String>{'all': 'Toutes', for (final c in cats) c: c};
                final current = filters.containsKey(_filter) ? _filter : 'all';
                final items = all.where((g) => current == 'all' || g.category == current).toList();

                return Column(
                  children: [
                    if (cats.isNotEmpty)
                      FilterBar(options: filters, selected: current, onChanged: (v) => setState(() => _filter = v)),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final g = items[i];
                          return GestureDetector(
                            onTap: () => _open(g),
                            child: Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                AppImage(url: g.url, label: g.label, radius: 16),
                                if (g.isVideo)
                                  const Center(child: Icon(Icons.play_circle_fill, size: 44, color: AppColors.vert)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
