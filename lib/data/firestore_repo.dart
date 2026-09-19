import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

/// Passerelle Firestore <-> modèles de l'app.
/// Schéma attendu pour un document de la collection `projects` :
///   title (string), category (string), summary (string), description (string?),
///   imageUrl (string?), goal (number?), collected (number, défaut 0),
///   status (string: 'en_cours' | 'realise' | 'a_venir'), published (bool),
///   createdAt (timestamp)
class FirestoreRepo {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Project>> watchProjects() {
    return _db
        .collection('projects')
        .where('published', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_projectFromDoc).toList());
  }

  static Project _projectFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Project(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      summary: (d['summary'] ?? '') as String,
      description: d['description'] as String?,
      imageUrl: d['imageUrl'] as String?,
      goal: (d['goal'] as num?)?.toInt(),
      collected: (d['collected'] as num?)?.toInt() ?? 0,
      status: _statusFromString(d['status'] as String?),
    );
  }

  static ProjectStatus _statusFromString(String? value) {
    switch (value) {
      case 'realise':
        return ProjectStatus.realise;
      case 'a_venir':
        return ProjectStatus.aVenir;
      case 'en_cours':
      default:
        return ProjectStatus.enCours;
    }
  }
}
