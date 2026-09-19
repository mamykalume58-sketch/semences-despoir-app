import 'package:flutter/foundation.dart';

/// Envoi des formulaires. Pour l'instant : simulation (même comportement que le site
/// web avant branchement Firebase). Quand Firestore sera configuré, remplacer
/// _simulate() par un addDoc() vers : donations, volunteers, contactMessages, newsletter
/// (schéma décrit dans le README du projet web).
class SubmissionService {
  SubmissionService._();

  static Future<void> _simulate(String kind, Map<String, dynamic> data) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    debugPrint('[$kind] $data');
  }

  static Future<void> submitDonation(Map<String, dynamic> data) => _simulate('donations', data);
  static Future<void> submitVolunteer(Map<String, dynamic> data) => _simulate('volunteers', data);
  static Future<void> submitContactMessage(Map<String, dynamic> data) => _simulate('contactMessages', data);
  static Future<void> subscribeNewsletter(String email) => _simulate('newsletter', {'email': email});
}
