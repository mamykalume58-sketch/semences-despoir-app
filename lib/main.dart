import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/app_info.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

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
        final padding = MediaQuery.of(context).padding;
        return Stack(
          children: [
            if (child != null) child,
            // Bandeaux dorés peints par-dessus : Android 15+ ignore la
            // couleur native des barres système (edge-to-edge forcé), donc
            // on reproduit l'effet visuel nous-mêmes, à l'exact emplacement
            // des vraies barres.
            Positioned(
              top: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(height: padding.top, color: const Color(0xFFB8860B)),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(height: padding.bottom, color: const Color(0xFFB8860B)),
              ),
            ),
          ],
        );
      },
    );
  }
}
