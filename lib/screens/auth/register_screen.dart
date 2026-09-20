import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/member_service.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Uint8List? _photoBytes;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Champ obligatoire';
    if (v.length < 6) return '6 caractères minimum';
    return null;
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('email-already-in-use')) return 'Un compte existe déjà avec cet email.';
    if (s.contains('invalid-email')) return 'Adresse e-mail invalide.';
    if (s.contains('weak-password')) return 'Mot de passe trop faible (6 caractères minimum).';
    if (s.contains('network')) return 'Problème de connexion internet.';
    return 'Une erreur est survenue. Merci de réessayer.';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final credential = await AuthService.registerWithEmail(_email.text.trim(), _password.text);
      final uid = credential.user?.uid;
      if (uid != null) {
        await MemberService.createMemberProfile(
          uid: uid,
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          photoBytes: _photoBytes,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppSnack(context, _friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHero(
              eyebrow: 'Rejoignez-nous',
              subtitle: 'Créez votre compte pour devenir membre de notre communauté.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FormCard(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.vertClair,
                        backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                        child: _photoBytes == null
                            ? const Icon(Icons.add_a_photo_outlined, color: AppColors.vert, size: 28)
                            : null,
                      ),
                    ),
                  ),
                  const Gap(6),
                  Center(child: Text('Photo de profil', style: AppText.small)),
                  const Gap(18),
                  TextFormField(
                    controller: _name,
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
                    controller: _password,
                    obscureText: true,
                    validator: _passwordValidator,
                    decoration: inputDecoration('Mot de passe'),
                  ),
                  const Gap(18),
                  LoadingButton(label: "S'inscrire", loading: _loading, onPressed: _submit),
                  const Gap(20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Déjà un compte ? Se connecter'),
                    ),
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
