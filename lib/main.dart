// lib/main.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Páginas principales
import 'pages/inicio_page.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/survey_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializa Firebase solo si no existe
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase inicializado correctamente");
    } else {
      debugPrint("⚠️ Firebase ya estaba inicializado, se omite inicialización");
    }
  } catch (e, st) {
    debugPrint("❌ Error inicializando Firebase: $e\n$st");
  }

  runApp(const CerebrilloApp());
}

class CerebrilloApp extends StatefulWidget {
  const CerebrilloApp({super.key});

  @override
  State<CerebrilloApp> createState() => _CerebrilloAppState();
}

class _CerebrilloAppState extends State<CerebrilloApp> {
  ThemeMode _themeMode = ThemeMode.light; // 🔹 Inicia en modo claro

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cerebrillo',
      debugShowCheckedModeBanner: false,

      // 🔹 Tema claro (tu diseño actual, no lo tocamos)
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),

      // 🔹 Tema oscuro inicial (luego personalizamos pantalla por pantalla)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.6),
            foregroundColor: Colors.white,
          ),
        ),
      ),

      themeMode: _themeMode, // 🔹 Control del tema

      home: InicioPage(
        onThemeChanged: _toggleTheme, // 🔹 Paso el callback al inicio
      ),

      routes: {
        '/welcome': (context) => WelcomePage(onThemeChanged: (bool isDark) {  },),
        '/login': (context) => LoginPage(onThemeChanged: (bool isDark) {  },),
        '/register': (context) => RegisterPage(onThemeChanged: (bool isDark) {  },),
        '/survey': (context) => SurveyPage(onSurveyComplete: (List<int> answers) {}),
        '/home': (context) => HomePage(onThemeChanged: (bool isDark) {  },),
      },
    );
  }
}
