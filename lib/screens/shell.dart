import 'package:flutter/material.dart';

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
            const DonateScreen(),
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
