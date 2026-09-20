import 'package:flutter/material.dart';

import 'models.dart';

/// Données de démonstration (reprises du site web). À remplacer par Firestore plus tard :
/// projects, news, gallery, siteSettings/stats (voir README du projet web).
class DemoData {
  DemoData._();

  static const stats = <Stat>[
    Stat('520+', 'Personnes aidées'),
    Stat('12', 'Projets réalisés'),
    Stat('45+', 'Bénévoles'),
    Stat('3', "Années d'engagement"),
  ];

  static const actions = <ActionArea>[
    ActionArea(
      id: 'personnes-agees',
      title: 'Personnes âgées',
      description: 'Visites régulières, assistance au quotidien et moments de partage.',
      count: 18,
      icon: Icons.elderly,
      adminCategory: 'Personnes âgées',
    ),
    ActionArea(
      id: 'veuves',
      title: 'Veuves',
      description: 'Soutien matériel, accompagnement humain et écoute.',
      count: 9,
      icon: Icons.favorite_border,
      adminCategory: 'Veuves',
    ),
    ActionArea(
      id: 'orphelins',
      title: 'Orphelins',
      description: 'Éducation, fournitures scolaires et suivi de bien-être.',
      count: 14,
      icon: Icons.school_outlined,
      adminCategory: 'Orphelins',
    ),
    ActionArea(
      id: 'nourriture',
      title: 'Nourriture',
      description: 'Distribution alimentaire régulière pour les familles en difficulté.',
      count: 22,
      icon: Icons.restaurant_outlined,
      adminCategory: 'Nourriture',
    ),
    ActionArea(
      id: 'communautes',
      title: 'Communautés',
      description: 'Actions solidaires au bénéfice du plus grand nombre.',
      count: 11,
      icon: Icons.groups_outlined,
      adminCategory: 'Communautés',
    ),
    ActionArea(
      id: 'autres',
      title: 'Autres initiatives',
      description: 'Projets divers, nés directement des besoins constatés sur le terrain.',
      count: 6,
      icon: Icons.auto_awesome_outlined,
      adminCategory: 'Autres',
    ),
  ];

  static final projects = <Project>[
    Project(
      id: 'orphelins',
      title: 'Soutien aux orphelins',
      category: 'Éducation',
      summary: 'Fournitures scolaires, vêtements et accompagnement pour un avenir meilleur.',
      status: ProjectStatus.enCours,
      description:
          "Ce projet vise à fournir des fournitures scolaires, des vêtements et un accompagnement éducatif aux enfants orphelins de notre région. Nous croyons que chaque enfant mérite une chance de construire son avenir.",
      goal: 1000000,
      collected: 650000,
      deadline: DateTime(2027, 8, 20),
      objectives: const [
        'Équiper 150 enfants en fournitures scolaires',
        'Financer les frais de scolarité de 40 orphelins',
        'Organiser un suivi psychosocial mensuel',
      ],
      updates: const [
        ProjectUpdate('12 août 2026', 'Distribution de la première vague de kits scolaires réalisée.'),
        ProjectUpdate('2 juillet 2026', 'Lancement officiel de la collecte auprès des donateurs.'),
      ],
      transparency:
          "65 % des fonds collectés ont déjà été utilisés pour l'achat de fournitures scolaires ; le solde est réservé aux frais de scolarité du second trimestre.",
      galleryCount: 3,
    ),
    const Project(
      id: 'personnes-agees',
      title: 'Visites aux personnes âgées',
      category: 'Personnes âgées',
      summary: 'Aide alimentaire, soins et moments de partage.',
      status: ProjectStatus.enCours,
      goal: 800000,
      collected: 320000,
    ),
    const Project(
      id: 'nourriture',
      title: 'Distribution de nourriture',
      category: 'Aide alimentaire',
      summary: 'Soutien alimentaire pour 200 familles en difficulté.',
      status: ProjectStatus.realise,
      goal: 1500000,
      collected: 1500000,
    ),
    const Project(
      id: 'kits-scolaires-2027',
      title: 'Kits scolaires 2027',
      category: 'Éducation',
      summary: 'Préparation de la rentrée scolaire pour 150 enfants orphelins.',
      status: ProjectStatus.aVenir,
    ),
  ];

  /// Options de la page Don (id → libellé).
  static const donationTargets = <String, String>{
    'general': 'Là où le besoin est le plus urgent',
    'Personnes âgées': 'Personnes âgées',
    'Veuves': 'Veuves',
    'Orphelins': 'Orphelins',
    'Nourriture': 'Nourriture',
    'Communautés': 'Communautés',
    'Autres': 'Autres initiatives',
  };

  static const newsCategories = <String, String>{
    'actions': 'Nos actions',
    'projets': 'Projets',
    'evenements': 'Événements',
  };

  static final news = <NewsItem>[
    NewsItem(
      id: 'visite-aines',
      title: "Vivre pour les Autres visite 30 personnes âgées à Lubumbashi",
      category: 'actions',
      summary: 'Une journée de partage et d\'assistance pour apporter un peu de réconfort à nos aînés.',
      date: DateTime(2026, 9, 11),
      paragraphs: const [
        "Ce samedi, nos bénévoles se sont rendus dans trois quartiers de Lubumbashi pour rendre visite à une trentaine de personnes âgées. Au programme : distribution de vivres, soins de base et surtout, du temps passé ensemble.",
        "Cette action s'inscrit dans notre engagement continu envers les aînés de nos communautés, souvent isolés et oubliés. Chaque visite est aussi l'occasion d'évaluer les besoins spécifiques de chaque personne pour un suivi personnalisé.",
      ],
    ),
    NewsItem(
      id: 'fournitures-scolaires',
      title: 'Distribution de fournitures scolaires pour les orphelins',
      category: 'projets',
      summary: 'Les enfants ont reçu leurs kits scolaires pour bien préparer la rentrée.',
      date: DateTime(2026, 4, 10),
      paragraphs: const ['Les enfants ont reçu leurs kits scolaires pour bien préparer la rentrée.'],
    ),
    NewsItem(
      id: 'campagne-alimentaire',
      title: 'Grande campagne alimentaire dans la communauté',
      category: 'evenements',
      summary: "Plus de 200 familles ont bénéficié de notre aide alimentaire cette semaine.",
      date: DateTime(2026, 4, 2),
      paragraphs: const ["Plus de 200 familles ont bénéficié de notre aide alimentaire cette semaine."],
    ),
  ];

  static const galleryCategories = <String, String>{
    'actions': 'Actions',
    'projets': 'Projets',
    'evenements': 'Événements',
    'videos': 'Vidéos',
  };

  /// Vignettes de démonstration (comme sur le site web).
  static const gallery = <GalleryItem>[
    GalleryItem('Visite aux aînés', 'actions'),
    GalleryItem('Kits scolaires', 'projets'),
    GalleryItem('Campagne alimentaire', 'evenements'),
    GalleryItem('Témoignage', 'actions', isVideo: true),
    GalleryItem('Distribution de vivres', 'actions'),
    GalleryItem('Rentrée des orphelins', 'projets'),
    GalleryItem('Journée solidaire', 'evenements'),
    GalleryItem('Reportage terrain', 'projets', isVideo: true),
    GalleryItem('Équipe de bénévoles', 'evenements'),
  ];
}
