/// Index des onglets de la barre de navigation basse.
class AppTab {
  AppTab._();
  static const int home = 0;
  static const int projects = 1;
  static const int donate = 2;
  static const int news = 3;
  static const int more = 4;
}

const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String formatDateFr(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatFc(int n) {
  final s = n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
  return '$s FC';
}

String? requiredValidator(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

String? emailValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Adresse e-mail invalide';
}
