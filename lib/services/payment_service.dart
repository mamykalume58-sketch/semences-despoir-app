import 'dart:convert';
import 'package:http/http.dart' as http;

/// Appelle le Worker Cloudflare qui fait le pont avec l'API Shwary
/// (paiement Mobile Money RDC) et écrit le résultat dans Firestore.
class PaymentService {
  PaymentService._();

  static const _baseUrl = 'https://semences-despoir-shwary.mamykalume58.workers.dev';

  /// Convertit un numéro local (ex: "0812345678" ou "812345678")
  /// au format international attendu par Shwary (+243...).
  static String normalizePhone(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digitsOnly.startsWith('+243')) return digitsOnly;
    if (digitsOnly.startsWith('243')) return '+$digitsOnly';
    if (digitsOnly.startsWith('0')) return '+243${digitsOnly.substring(1)}';
    return '+243$digitsOnly';
  }

  /// Initie un paiement Mobile Money. Retourne l'ID de la transaction
  /// (= ID du document Firestore dans `donations`) en cas de succès.
  static Future<String> payMobileMoney({
    required int amount,
    required String phone,
    required String donorName,
    required String project,
    String? projectTitle,
    String? userId,
    bool sandbox = false,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'clientPhoneNumber': normalizePhone(phone),
        'donorName': donorName,
        'project': project,
        'projectTitle': projectTitle,
        'userId': userId,
        'sandbox': sandbox,
      }),
    ).timeout(const Duration(seconds: 30));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] as String? ?? 'Erreur de paiement inconnue.');
    }

    return data['id'] as String;
  }
}
