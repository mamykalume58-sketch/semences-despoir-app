import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Collection `members/{uid}` : profil du membre inscrit dans l'app.
/// name, phone, photoUrl (base64), createdAt.
class MemberModel {
  const MemberModel({required this.name, required this.phone, this.photoUrl});

  final String name;
  final String phone;
  final String? photoUrl;

  factory MemberModel.fromMap(Map<String, dynamic> d) {
    final photo = (d['photoUrl'] ?? '').toString();
    return MemberModel(
      name: (d['name'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      photoUrl: photo.isEmpty ? null : photo,
    );
  }
}

class MemberService {
  static final _db = FirebaseFirestore.instance;

  static Future<String> _encodePhoto(Uint8List bytes) async {
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  static Future<void> createMemberProfile({
    required String uid,
    required String name,
    required String phone,
    Uint8List? photoBytes,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (photoBytes != null) {
      data['photoUrl'] = await _encodePhoto(photoBytes);
    }
    await _db.collection('members').doc(uid).set(data, SetOptions(merge: true));
  }

  static Stream<MemberModel?> watchMember(String uid) {
    return _db.collection('members').doc(uid).snapshots().map((snap) {
      final d = snap.data();
      return d == null ? null : MemberModel.fromMap(d);
    });
  }
}
