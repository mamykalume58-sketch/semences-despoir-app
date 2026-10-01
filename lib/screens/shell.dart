import 'package:flutter/material.dart';
import '../services/version_service.dart';
import '../widgets/update_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme.dart';
import '../utils.dart';
import 'donate_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'news_screen.dart';
import 'projects_screen.dart';

/// Écran principal : barre de navigation basse à 5 onglets.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = AppTab.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final info = await VersionService().checkForUpdate();
      if (!mounted) return;
      if (info != null) {
        await showUpdateDialog(context, info: info);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            'DEBUG — package: ${pkg.packageName}, code installé: ${pkg.buildNumber} → aucune mise à jour détectée (null)',
          ),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 15),
        content: Text('DEBUG — erreur vérification mise à jour : $e'),
      ));
    }
  }

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Retour système : d'abord revenir à l'accueil, puis quitter.
      canPop: _index == AppTab.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goTo(AppTab.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onGoTo: _goTo),
            const ProjectsScreen(),
            DonateScreen(onGoTo: _goTo),
            const NewsScreen(),
            const MoreScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.vert),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_special_outlined),
              selectedIcon: Icon(Icons.folder_special, color: AppColors.vert),
              label: 'Projets',
            ),
            NavigationDestination(
              icon: Icon(Icons.volunteer_activism_outlined),
              selectedIcon: Icon(Icons.volunteer_activism, color: AppColors.vert),
              label: 'Don',
            ),
            NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article, color: AppColors.vert),
              label: 'Actualités',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz, color: AppColors.vert),
              label: 'Plus',
            ),
          ],
        ),
      ),
    );
  }
}
