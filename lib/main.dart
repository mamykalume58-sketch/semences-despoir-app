import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/app_info.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
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
    );
  }
}
