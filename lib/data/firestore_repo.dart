import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

/// Passerelle Firestore <-> modèles de l'app.
/// Schéma réel écrit par l'admin (src/pages/projects/ProjectForm.jsx) pour
/// un document de la collection `projects` :
///   title (string), category (string), shortDescription (string),
///   description (string?), imageUrl (string?), goalAmount (number),
///   collectedAmount (number), status (string: 'brouillon' | 'en_cours' | 'termine' | 'archive'),
///   published (bool, vrai seulement si status est 'en_cours' ou 'termine'),
///   createdAt (timestamp)
class FirestoreRepo {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Project>> watchProjects() {
    return _db
        .collection('projects')
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snap) {
      DateTime t(QueryDocumentSnapshot<Map<String, dynamic>> d) {
        final v = d.data()['createdAt'];
        return v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      }

      final docs = snap.docs.toList();
      docs.sort((a, b) => t(b).compareTo(t(a)));
      return docs.map(_projectFromDoc).toList();
    });
  }

  static Project _projectFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Project(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      summary: (d['shortDescription'] ?? '') as String,
      description: d['description'] as String?,
      imageUrl: d['imageUrl'] as String?,
      goal: (d['goalAmount'] as num?)?.toInt(),
      collected: (d['collectedAmount'] as num?)?.toInt() ?? 0,
      status: _statusFromString(d['status'] as String?),
    );
  }

  static ProjectStatus _statusFromString(String? value) {
    switch (value) {
      case 'termine':
        return ProjectStatus.realise;
      case 'a_venir':
        return ProjectStatus.aVenir;
      case 'en_cours':
      default:
        return ProjectStatus.enCours;
    }
  }
}
