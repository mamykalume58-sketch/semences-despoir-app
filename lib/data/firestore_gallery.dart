import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

/// Collection `gallery` (admin : GalleryList.jsx) : imageUrl (base64), caption,
/// category, type ('photo'), createdAt. Lecture publique autorisée par les règles.
class FirestoreGallery {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<GalleryItem>> watchGallery() {
    return _db.collection('gallery').snapshots().map((snap) {
      DateTime t(QueryDocumentSnapshot<Map<String, dynamic>> d) {
        final v = d.data()['createdAt'];
        return v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
      }

      final docs = snap.docs.toList();
      docs.sort((a, b) => t(b).compareTo(t(a)));
      return docs.map(_fromDoc).toList();
    });
  }

  static GalleryItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final caption = (d['caption'] ?? '').toString().trim();
    final img = (d['imageUrl'] ?? '').toString();
    return GalleryItem(
      caption.isEmpty ? 'Photo' : caption,
      (d['category'] ?? '').toString().trim(),
      isVideo: d['type'] == 'video',
      url: img.isEmpty ? null : img,
    );
  }
}
