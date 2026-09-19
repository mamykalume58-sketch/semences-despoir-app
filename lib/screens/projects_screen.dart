import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  static const _filters = <String, String>{
    'all': 'Tous',
    'en-cours': 'En cours',
    'realise': 'Réalisés',
    'a-venir': 'À venir',
  };

  String _filter = 'all';

  bool _matches(Project p) {
    switch (_filter) {
      case 'en-cours':
        return p.status == ProjectStatus.enCours;
      case 'realise':
        return p.status == ProjectStatus.realise;
      case 'a-venir':
        return p.status == ProjectStatus.aVenir;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = DemoData.projects.where(_matches).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Nos projets')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHero(eyebrow: 'Impact durable', subtitle: 'Des projets concrets, financés par votre générosité.'),
          FilterBar(options: _filters, selected: _filter, onChanged: (v) => setState(() => _filter = v)),
          const Gap(16),
          for (final p in items)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ProjectCard(project: p),
            ),
        ],
      ),
    );
  }
}
