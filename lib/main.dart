import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/app_info.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

/// Faux tant que le splash screen est affiché (fond vert plein écran),
/// activé dès que MainShell se lance : la bande dorée du bas n'apparaît
/// qu'à partir de là, pour ne pas trancher avec le splash.
final ValueNotifier<bool> showGoldSystemBar = ValueNotifier<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SemencesApp());
}

class SemencesApp extends StatelessWidget {
  const SemencesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
      builder: (context, child) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        return Stack(
          children: [
            if (child != null) child,
            // Bande dorée sur la vraie barre système du bas (navigation) :
            // Android 15+ ignore la couleur native, donc on la peint nous-mêmes.
            // Masquée tant qu'on est sur le splash (voir showGoldSystemBar).
            ValueListenableBuilder<bool>(
              valueListenable: showGoldSystemBar,
              builder: (context, show, _) {
                if (!show) return const SizedBox.shrink();
                return Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: IgnorePointer(
                    child: Container(height: bottomPadding, color: const Color(0xFFB8860B)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
