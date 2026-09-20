import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils.dart';

/// Collection `actions` (admin : src/pages/actions/ActionForm.jsx) :
///   title, description, category ('Personnes âgées' | 'Veuves' | 'Orphelins' |
///   'Nourriture' | 'Communautés' | 'Autres'), location, date ('AAAA-MM-JJ'), time,
///   beneficiaires, imageUrl (base64), status, published (exigé par les règles), createdAt.
class ActionItem {
  const ActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.location,
    this.date = '',
    this.time = '',
    this.beneficiaires = 0,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final DateTime createdAt;
  final String? location;
  final String date;
  final String time;
  final int beneficiaires;
  final String? imageUrl;

  String get statusLabel {
    switch (status) {
      case 'planifiee':
        return 'Planifiée';
      case 'en_cours':
        return 'En cours';
      case 'realisee':
      case 'terminee':
      case 'termine':
        return 'Réalisée';
      case 'annulee':
        return 'Annulée';
      default:
        return status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
    }
  }

  String? get whenLabel {
    if (date.isEmpty) return null;
    final d = DateTime.tryParse(date);
    final base = d != null ? formatDateFr(d) : date;
    return time.isEmpty ? base : '$base à $time';
  }
}

class FirestoreActions {
  static final _db = FirebaseFirestore.instance;

  /// Les règles n'autorisent la lecture publique que si published == true.
  /// Tri côté app (pas d'index composite nécessaire).
  static Stream<List<ActionItem>> watchActions() {
    return _db
        .collection('actions')
        .where('published', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(_fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static ActionItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    String s(String k) => (d[k] ?? '').toString().trim();
    final img = s('imageUrl');
    final loc = s('location');
    final ben = d['beneficiaires'];
    final ts = d['createdAt'];
    return ActionItem(
      id: doc.id,
      title: s('title'),
      description: s('description'),
      category: s('category'),
      status: s('status'),
      location: loc.isEmpty ? null : loc,
      date: s('date'),
      time: s('time'),
      beneficiaires: ben is num ? ben.toInt() : (int.tryParse('$ben') ?? 0),
      imageUrl: img.isEmpty ? null : img,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
