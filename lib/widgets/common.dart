import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

// ---------- Liens externes & messages ----------

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.erreur : AppColors.vertFonce,
      duration: const Duration(seconds: 3),
    ));
}

Future<void> openLink(BuildContext context, String? url) async {
  if (url == null || url.isEmpty) {
    showAppSnack(context, 'Lien bientôt disponible.');
    return;
  }
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    showAppSnack(context, "Impossible d'ouvrir ce lien.", error: true);
  }
}

// ---------- Marque ----------

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.vertClair, shape: BoxShape.circle),
      child: Icon(Icons.eco_outlined, color: AppColors.vert, size: size * 0.6),
    );
  }
}

// ---------- Titres ----------

class SectionHead extends StatelessWidget {
  const SectionHead({super.key, this.eyebrow, required this.title, this.subtitle});
  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(eyebrow!.toUpperCase(), style: AppText.eyebrow),
            const SizedBox(height: 6),
          ],
          Text(title, style: AppText.h2),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: AppText.body),
          ],
        ],
      ),
    );
  }
}

/// Bandeau d'introduction des écrans (le titre est déjà dans l'AppBar).
class PageHero extends StatelessWidget {
  const PageHero({super.key, required this.eyebrow, required this.subtitle});
  final String eyebrow;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.vertClair, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: AppText.eyebrow),
          const SizedBox(height: 6),
          Text(subtitle, style: AppText.body.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

// ---------- Cartes & images ----------

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF1EF)),
        boxShadow: const [
          BoxShadow(color: Color(0x14063B2A), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

/// Image réseau si [url] est renseignée, sinon encadré placeholder identifié.
class AppImage extends StatelessWidget {
  const AppImage({super.key, this.url, required this.label, this.aspectRatio, this.radius = 16});
  final String? url;
  final String label;
  final double? aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    Widget child;
    if (hasUrl && url!.startsWith('data:')) {
      // Image encodée en base64 (écrite par l'admin) : décodage local, pas de requête réseau.
      try {
        final base64Part = url!.substring(url!.indexOf(',') + 1);
        child = Container(
          color: AppColors.vertClair,
          child: Image.memory(
          base64Decode(base64Part),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _Placeholder(label),
        );
        );
      } catch (_) {
        child = _Placeholder(label);
      }
    } else if (hasUrl) {
      child = Container(
        color: AppColors.vertClair,
        child: Image.network(
        url!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _Placeholder(label),
      );
      );
    } else {
      child = _Placeholder(label);
    }
    child = ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
    if (aspectRatio != null) {
      return AspectRatio(aspectRatio: aspectRatio!, child: child);
    }
    return child;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.vertClair, Color(0xFFD7EFE0)],
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.vert),
      ),
    );
  }
}

// ---------- Progression ----------

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 8,
          backgroundColor: AppColors.vertClair,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vert),
        ),
      ),
    );
  }
}

// ---------- Boutons ----------

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.small = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool small;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(vertical: small ? 10 : 15, horizontal: small ? 18 : 24);
    final textStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: small ? 13 : 15);
    final Widget btn = outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.vert,
              side: const BorderSide(color: AppColors.vert, width: 1.5),
              padding: padding,
              shape: const StadiumBorder(),
              textStyle: textStyle,
            ),
            child: Text(label),
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.vert,
              foregroundColor: Colors.white,
              padding: padding,
              shape: const StadiumBorder(),
              textStyle: textStyle,
            ),
            child: Text(label),
          );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key, required this.label, required this.loading, required this.onPressed});
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.vert,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}

// ---------- Filtres ----------

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.options, required this.selected, required this.onChanged});
  final Map<String, String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final e in options.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppChoice(
                label: e.value,
                selected: e.key == selected,
                onTap: () => onChanged(e.key),
              ),
            ),
        ],
      ),
    );
  }
}

class AppChoice extends StatelessWidget {
  const AppChoice({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.vert,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.vert : const Color(0xFFD5DED9)),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.texte,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

/// Tuile sélectionnable (remplace les radio buttons / listes déroulantes).
class SelectableTile extends StatelessWidget {
  const SelectableTile({super.key, required this.title, this.subtitle, required this.selected, required this.onTap});
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.vertClair : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.vert : AppColors.bordure,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.vert : AppColors.texteSecondaire,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppText.small),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Formulaires ----------

InputDecoration inputDecoration(String label, {String? hint}) {
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: AppColors.grisClair,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: border(AppColors.bordure),
    enabledBorder: border(AppColors.bordure),
    focusedBorder: border(AppColors.vert, 1.6),
    errorBorder: border(AppColors.erreur),
    focusedErrorBorder: border(AppColors.erreur, 1.6),
  );
}

class FormCard extends StatelessWidget {
  const FormCard({super.key, this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: AppText.h3),
              const SizedBox(height: 14),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class Gap extends StatelessWidget {
  const Gap(this.h, {super.key});
  final double h;
  @override
  Widget build(BuildContext context) => SizedBox(height: h);
}
