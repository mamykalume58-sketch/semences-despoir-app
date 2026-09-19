import 'package:flutter/material.dart';

import '../services/submissions.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
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

  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _why = TextEditingController();
  final _message = TextEditingController();

  String _skill = 'education';
  String _availability = 'weekends';
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_fullName, _phone, _email, _city, _why, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await SubmissionService.submitVolunteer({
        'fullName': _fullName.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'city': _city.text.trim(),
        'skill': _skill,
        'availability': _availability,
        'why': _why.text.trim(),
        'message': _message.text.trim(),
      });
      if (!mounted) return;
      showAppSnack(context, 'Merci ! Votre candidature a bien été envoyée. Nous reviendrons vers vous très vite.');
      for (final c in [_fullName, _phone, _email, _city, _why, _message]) {
        c.clear();
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'Une erreur est survenue. Merci de réessayer dans un instant.', error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _choices(Map<String, String> options, String selected, ValueChanged<String> onPick) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in options.entries)
          AppChoice(label: e.value, selected: selected == e.key, onTap: () => onPick(e.key)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devenir bénévole')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHero(
              eyebrow: 'Rejoignez-nous',
              subtitle: 'Votre temps et vos compétences peuvent faire la différence.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const _Benefit(emoji: '🤲', title: 'Agir pour les autres', text: 'Mettez vos compétences au service de ceux qui en ont le plus besoin.'),
                  const _Benefit(emoji: '✨', title: 'Vivre une expérience enrichissante', text: "Chaque mission apporte autant qu'elle donne."),
                  const _Benefit(emoji: '🌍', title: 'Faire partie d\'une communauté engagée', text: 'Rejoignez un réseau de bénévoles passionnés et solidaires.'),
                  const Gap(8),
                  FormCard(
                    title: 'Ma candidature',
                    children: [
                      TextFormField(
                        controller: _fullName,
                        textCapitalization: TextCapitalization.words,
                        validator: requiredValidator,
                        decoration: inputDecoration('Nom complet'),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: requiredValidator,
                        decoration: inputDecoration('Téléphone'),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                        decoration: inputDecoration('Email'),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _city,
                        textCapitalization: TextCapitalization.words,
                        validator: requiredValidator,
                        decoration: inputDecoration('Ville'),
                      ),
                      const Gap(18),
                      const Text('Domaine de compétence', style: AppText.h3),
                      const Gap(10),
                      _choices(_skills, _skill, (v) => setState(() => _skill = v)),
                      const Gap(18),
                      const Text('Disponibilité', style: AppText.h3),
                      const Gap(10),
                      _choices(_availabilities, _availability, (v) => setState(() => _availability = v)),
                      const Gap(18),
                      TextFormField(
                        controller: _why,
                        minLines: 3,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        validator: requiredValidator,
                        decoration: inputDecoration("Pourquoi voulez-vous rejoindre Les Semences d'Espoir ?"),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _message,
                        minLines: 2,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: inputDecoration('Message (optionnel)'),
                      ),
                      const Gap(18),
                      LoadingButton(label: 'Envoyer ma candidature', loading: _loading, onPressed: _submit),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.emoji, required this.title, required this.text});
  final String emoji;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.vertClair, borderRadius: BorderRadius.circular(12)),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h3),
                const SizedBox(height: 4),
                Text(text, style: AppText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
