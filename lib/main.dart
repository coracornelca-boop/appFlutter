import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/login_screen.dart';
import 'screens/recipes/recipes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jbpegrkpmmijbtstumii.supabase.co',
    publishableKey: 'sb_publishable_MX82k2sQsXhLDf9n53DM0g_AmAyz8JZ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Vérifie si un utilisateur est déjà connecté.
  bool get _isLoggedIn =>
      Supabase.instance.client.auth.currentSession != null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PyCook Recipes',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.zero,
        ),
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/recipes': (context) => const RecipesScreen(),
      },

      home: _isLoggedIn ? const RecipesScreen() : const LoginScreen(),
    );
  }
}