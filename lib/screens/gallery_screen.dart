import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static final _filters = <String, String>{'all': 'Toutes', ...DemoData.galleryCategories};
  String _filter = 'all';

  bool _matches(GalleryItem g) {
    if (_filter == 'all') return true;
    if (_filter == 'videos') return g.isVideo;
    return g.category == _filter;
  }

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
              Text(g.label, style: AppText.h3),
              const SizedBox(height: 4),
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fermer')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = DemoData.gallery.where(_matches).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Galerie')),
      body: Column(
        children: [
          const PageHero(eyebrow: 'En images', subtitle: 'Photos et vidéos de nos actions sur le terrain.'),
          FilterBar(options: _filters, selected: _filter, onChanged: (v) => setState(() => _filter = v)),
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
      ),
    );
  }
}
