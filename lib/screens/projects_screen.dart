import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/firestore_repo.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nos projets')),
      body: StreamBuilder<List<Project>>(
        stream: FirestoreRepo.watchProjects(),
        builder: (context, snapshot) {
          // Tant que l'admin n'a rien publié (ou en cas d'erreur réseau),
          // on retombe sur les projets de démonstration plutôt que d'afficher un écran vide.
          final source = (snapshot.hasData && snapshot.data!.isNotEmpty)
              ? snapshot.data!
              : DemoData.projects;
          final items = source.where(_matches).toList();

          return ListView(
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
          );
        },
      ),
    );
  }
}
