import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets/common.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('user-not-found') || s.contains('wrong-password') || s.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (s.contains('invalid-email')) return 'Adresse e-mail invalide.';
    if (s.contains('too-many-requests')) return 'Trop de tentatives. Réessayez plus tard.';
    if (s.contains('network')) return 'Problème de connexion internet.';
    return 'Une erreur est survenue. Merci de réessayer.';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await AuthService.signInWithEmail(_email.text.trim(), _password.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppSnack(context, _friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (result != null && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppSnack(context, _friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      showAppSnack(context, 'Renseignez votre email ci-dessus, puis appuyez à nouveau.', error: true);
      return;
    }
    try {
      await AuthService.resetPassword(_email.text.trim());
      if (mounted) showAppSnack(context, 'Un email de réinitialisation vous a été envoyé.');
    } catch (e) {
      if (mounted) showAppSnack(context, _friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHero(
              eyebrow: 'Bon retour',
              subtitle: 'Connectez-vous pour retrouver votre espace membre.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FormCard(
                children: [
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
                    validator: requiredValidator,
                    decoration: inputDecoration('Mot de passe'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                  const Gap(6),
                  LoadingButton(label: 'Se connecter', loading: _loading, onPressed: _submit),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.bordure)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('ou', style: AppText.small),
                      ),
                      Expanded(child: Divider(color: AppColors.bordure)),
                    ],
                  ),
                  const Gap(16),
                  LoadingButton(
                    label: 'Continuer avec Google',
                    loading: _googleLoading,
                    onPressed: _signInGoogle,
                  ),
                  const Gap(20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text("Pas encore de compte ? S'inscrire"),
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
