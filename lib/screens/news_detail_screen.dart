import 'package:flutter/material.dart';

import '../data/app_info.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.news});
  final NewsItem news;

  @override
  Widget build(BuildContext context) {
    final n = news;
    return Scaffold(
      appBar: AppBar(title: const Text('Actualité')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text((DemoData.newsCategories[n.category] ?? n.category).toUpperCase(), style: AppText.eyebrow),
          const Gap(8),
          Text(n.title, style: AppText.h1),
          const Gap(8),
          Text('${formatDateFr(n.date)}  •  Par ${n.author}', style: AppText.small),
          const Gap(16),
          AppImage(url: n.imageUrl, label: "Image principale de l'article", aspectRatio: 16 / 9, radius: 20),
          const Gap(20),
          for (final p in n.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(p, style: AppText.body.copyWith(fontSize: 15, color: AppColors.texte)),
            ),
          const Gap(10),
          AppButton(
            label: 'Partager sur WhatsApp',
            outlined: true,
            expand: true,
            onPressed: () {
              final text = Uri.encodeComponent('${n.title} — ${AppInfo.name}');
              openLink(context, 'https://wa.me/?text=$text');
            },
          ),
        ],
      ),
    );
  }
}
