import 'package:flutter/material.dart';

enum ProjectStatus { enCours, realise, aVenir }

extension ProjectStatusX on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.enCours:
        return 'En cours';
      case ProjectStatus.realise:
        return 'Réalisé';
      case ProjectStatus.aVenir:
        return 'À venir';
    }
  }
}

class Stat {
  const Stat(this.value, this.label);
  final String value;
  final String label;
}

class ProjectUpdate {
  const ProjectUpdate(this.date, this.text);
  final String date;
  final String text;
}

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.status,
    this.description,
    this.imageUrl,
    this.goal,
    this.collected = 0,
    this.objectives = const [],
    this.updates = const [],
    this.transparency,
    this.deadline,
    this.galleryCount = 0,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final ProjectStatus status;
  final String? description;
  final String? imageUrl;
  final int? goal;
  final int collected;
  final List<String> objectives;
  final List<ProjectUpdate> updates;
  final String? transparency;
  final DateTime? deadline;
  final int galleryCount;

  double get progress {
    final g = goal;
    if (g == null || g <= 0) return 0;
    return (collected / g).clamp(0.0, 1.0).toDouble();
  }

  String get percentLabel => '${(progress * 100).round()}%';
}

class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.date,
    required this.paragraphs,
    this.author = "L'équipe Vivre pour les Autres",
    this.imageUrl,
  });

  final String id;
  final String title;
  final String category; // actions | projets | evenements
  final String summary;
  final DateTime date;
  final List<String> paragraphs;
  final String author;
  final String? imageUrl;
}

class ActionArea {
  const ActionArea({
    required this.id,
    required this.title,
    required this.description,
    required this.count,
    required this.icon,
    required this.adminCategory,
  });

  final String id;
  final String title;
  final String description;
  final int count;
  final IconData icon;
  final String adminCategory;
}

class GalleryItem {
  const GalleryItem(this.label, this.category, {this.isVideo = false, this.url});
  final String label;
  final String category; // actions | projets | evenements
  final bool isVideo;
  final String? url;
}
