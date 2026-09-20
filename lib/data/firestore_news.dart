import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

/// Collection `news` (admin : src/pages/news/NewsForm.jsx) :
///   title, category ('Nos actions' | 'Projets' | 'Événements'), summary, content,
///   imageUrl (base64), status ('brouillon' | 'publie'), published (bool), createdAt.
/// Les événements sont les actualités de catégorie « Événements ».
class FirestoreNews {
  static final _db = FirebaseFirestore.instance;

  /// Pas de orderBy : where(published) + orderBy(createdAt) exigerait un index
  /// composite. Le tri par date se fait donc ici, côté app.
  static Stream<List<NewsItem>> watchNews() {
    return _db
        .collection('news')
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(_fromDoc).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  static NewsItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final content = (d['content'] ?? '').toString();
    final paragraphs = content
        .split(RegExp(r'\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    var summary = (d['summary'] ?? '').toString().trim();
    if (summary.isEmpty && paragraphs.isNotEmpty) summary = paragraphs.first;
    final img = d['imageUrl'] as String?;
    final ts = d['createdAt'];
    return NewsItem(
      id: doc.id,
      title: (d['title'] ?? '').toString(),
      category: _categoryId(d['category']?.toString()),
      summary: summary,
      date: ts is Timestamp ? ts.toDate() : DateTime.now(),
      paragraphs: paragraphs.isEmpty ? [summary] : paragraphs,
      imageUrl: (img == null || img.isEmpty) ? null : img,
    );
  }

  /// Libellés de l'admin -> identifiants utilisés par les filtres de l'app.
  static String _categoryId(String? label) {
    switch (label) {
      case 'Projets':
        return 'projets';
      case 'Événements':
        return 'evenements';
      case 'Nos actions':
      default:
        return 'actions';
    }
  }
}
