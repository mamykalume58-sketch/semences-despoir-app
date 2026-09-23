import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Appelle le Worker Cloudflare qui fait le pont avec l'API SasPay
/// (paiement Mobile Money RDC) et écrit le résultat dans Firestore.
class PaymentService {
  PaymentService._();

  static const _baseUrl = 'https://semences-despoir-shwary.mamykalume58.workers.dev';

  /// Génère une clé unique pour une tentative de don. À créer UNE FOIS par
  /// tentative (pas à chaque appel réseau), pour que SasPay puisse détecter
  /// un vrai retry et éviter de pousser deux demandes de paiement.
  static String newIdempotencyKey() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convertit un numéro local (ex: "0812345678" ou "812345678")
  /// au format international attendu par le Worker (+243...).
  static String normalizePhone(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digitsOnly.startsWith('+243')) return digitsOnly;
    if (digitsOnly.startsWith('243')) return '+$digitsOnly';
    if (digitsOnly.startsWith('0')) return '+243${digitsOnly.substring(1)}';
    return '+243$digitsOnly';
  }

  /// Initie un paiement Mobile Money. [network] doit être l'un de :
  /// 'airtel_cd', 'orange_cd', 'vodacom_cd'.
  /// Retourne l'ID de la transaction, son statut initial, et une éventuelle
  /// URL de paiement à ouvrir (certains réseaux redirigent au lieu de pousser).
  static Future<({String id, String status, String checkoutUrl})> payMobileMoney({
    required int amount,
    required String phone,
    required String donorName,
    required String project,
    required String network,
    required String idempotencyKey,
    String? projectTitle,
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
        'network': network,
        'idempotencyKey': idempotencyKey,
      }),
    ).timeout(const Duration(seconds: 30));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] as String? ?? 'Erreur de paiement inconnue.');
    }

    return (
      id: data['id'] as String,
      status: data['status'] as String? ?? 'PENDING',
      checkoutUrl: data['checkoutUrl'] as String? ?? '',
    );
  }

  /// Revérifie le statut réel d'un paiement auprès de SasPay (via le Worker)
  /// et renvoie le statut normalisé : 'confirme' | 'echoue' | 'pending'.
  static Future<String> verifyStatus(String donationId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/verify?id=$donationId'))
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] as String? ?? 'Vérification impossible.');
    }

    return data['status'] as String? ?? 'pending';
  }
}
