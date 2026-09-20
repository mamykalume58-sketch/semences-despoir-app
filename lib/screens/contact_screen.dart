import 'package:flutter/material.dart';

import '../services/submissions.dart';
import '../utils.dart';
import '../widgets/common.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _subject, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await SubmissionService.submitContactMessage({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'subject': _subject.text.trim(),
        'message': _message.text.trim(),
      });
      if (!mounted) return;
      showAppSnack(context, 'Merci ! Votre message a bien été envoyé.');
      for (final c in [_name, _email, _phone, _subject, _message]) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contactez-nous')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHero(eyebrow: 'Restons en contact', subtitle: 'Nous sommes à votre écoute.'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Gap(10),
                  FormCard(
                    title: 'Envoyez-nous un message',
                    children: [
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        validator: requiredValidator,
                        decoration: inputDecoration('Nom'),
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
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: inputDecoration('Téléphone (optionnel)'),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _subject,
                        validator: requiredValidator,
                        decoration: inputDecoration('Sujet'),
                      ),
                      const Gap(12),
                      TextFormField(
                        controller: _message,
                        minLines: 4,
                        maxLines: 8,
                        keyboardType: TextInputType.multiline,
                        validator: requiredValidator,
                        decoration: inputDecoration('Message'),
                      ),
                      const Gap(18),
                      LoadingButton(label: 'Envoyer le message', loading: _loading, onPressed: _submit),
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
