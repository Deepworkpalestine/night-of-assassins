import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_providers.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NightOfAssassinsApp(),
    ),
  );
}

class NightOfAssassinsApp extends StatelessWidget {
  const NightOfAssassinsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ليلة المغتالين',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'KOOkies',
        scaffoldBackgroundColor: const Color(0xFF120608),
        primaryColor: const Color(0xFFE53E3A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53E3A),
          secondary: Color(0xFFE53E3A),
          surface: Color(0xFF1B0E11),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
