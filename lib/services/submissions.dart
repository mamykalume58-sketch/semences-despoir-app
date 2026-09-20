import 'package:cloud_firestore/cloud_firestore.dart';

/// Envoi des formulaires vers Firestore. Les champs suivent les Security Rules
/// et les pages du site admin (volunteers, messages, newsletter, donations).
class SubmissionService {
  SubmissionService._();

  static final _db = FirebaseFirestore.instance;
  static const _timeout = Duration(seconds: 15);

  static const _skills = <String, String>{
    'education': 'Éducation',
    'sante': 'Santé',
    'logistique': 'Logistique',
    'communication': 'Communication',
    'autre': 'Autre',
  };
  static const _availabilities = <String, String>{
    'weekends': 'Week-ends',
    'soirs': 'Soirs de semaine',
    'flexible': 'Flexible',
  };

  static String _s(Object? v) => (v ?? '').toString().trim();

  static Future<void> _add(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data).timeout(_timeout);
  }

  static Future<void> submitDonation(Map<String, dynamic> data) {
    final amount = data['amount'];
    return _add('donations', {
      'donorName': _s(data['donorName']),
      'donorPhone': _s(data['donorPhone']),
      'amount': amount is num ? amount : (num.tryParse(_s(amount)) ?? 0),
      'currency': 'CDF',
      'projectId': _s(data['project']),
      'paymentMethod': _s(data['paymentMethod']),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> submitVolunteer(Map<String, dynamic> data) {
    final message = [_s(data['why']), _s(data['message'])].where((e) => e.isNotEmpty).join('\n\n');
    return _add('volunteers', {
      'fullName': _s(data['fullName']),
      'phone': _s(data['phone']),
      'email': _s(data['email']),
      'city': _s(data['city']),
      'skills': _skills[_s(data['skill'])] ?? _s(data['skill']),
      'availability': _availabilities[_s(data['availability'])] ?? _s(data['availability']),
      'message': message,
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> submitContactMessage(Map<String, dynamic> data) {
    return _add('messages', {
      'name': _s(data['name']),
      'email': _s(data['email']),
      'phone': _s(data['phone']),
      'subject': _s(data['subject']),
      'message': _s(data['message']),
      'status': 'unread',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> subscribeNewsletter(String email) {
    return _add('newsletter', {
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
