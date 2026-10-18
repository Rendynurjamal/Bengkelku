import 'package:flutter/material.dart';

import 'models/app_storage.dart';
import 'pages/splash_page.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  runApp(const BengkelKuApp());
}

class BengkelKuApp extends StatelessWidget {
  const BengkelKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppColors.themeMode,
      builder: (context, mode, _) {
        final brightness =
            mode == ThemeMode.light ? Brightness.light : Brightness.dark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BengkelKu',
          themeMode: mode,
          theme: ThemeData(
            brightness: brightness,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.gold,
              brightness: brightness,
            ),
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Arial',
          ),
          home: const SplashPage(),
        );
      },
    );
  }
}
