// SE QUEDA COMO ESTA 


// lib/pages/welcome_page.dart
// ignore_for_file: deprecated_member_use, unused_field, avoid_print, unused_import

import 'package:flutter/material.dart';
import 'dart:math';
import 'login_page.dart';
import 'register_page.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class WelcomePage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const WelcomePage({super.key, required this.onThemeChanged});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _buttonClickController;
  late Animation<double> _buttonScaleAnimation;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  bool _isDark = false;

  @override
  void initState() {
    super.initState();

    _buttonClickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _buttonClickController, curve: Curves.easeOut));

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation =
        Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final uid = userCredential.user?.uid;
      print("Usuario anónimo UID: $uid");

      if (uid != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Error al iniciar sesión anónimo: ${e.message}");
    }
  }

  @override
  void dispose() {
    _buttonClickController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String fondo = _isDark ? "assets/images/fondo0dark.jpg" : "assets/images/fondo0.jpg";
    final String imagenMujer = _isDark ? "assets/images/mujerdark.png" : "assets/images/mujer1.png";

    final List<Color> buttonLoginColors = _isDark
        ? [Color.fromARGB(255, 22, 32, 71), Color.fromARGB(255, 14, 0, 170)]
        : [Color.fromARGB(117, 231, 193, 252), Color.fromARGB(50, 223, 133, 210)];

    final List<Color> buttonRegisterColors = _isDark
        ? [Color.fromARGB(255, 22, 32, 71), Color.fromARGB(255, 14, 0, 170)]
        : [Color.fromARGB(73, 209, 160, 255), Color.fromARGB(76, 242, 153, 203)];

    return Scaffold(
      body: Stack(
        children: [
          // Fondo según tema
          SizedBox.expand(
            child: Image.asset(
              fondo,
              fit: BoxFit.cover,
            ),
          ),

          // Switch tema arriba derecha
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(
                    _isDark ? Icons.nights_stay : Icons.wb_sunny,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDark = !_isDark;
                    });
                    widget.onThemeChanged(_isDark);
                  },
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Contenedor Lottie + PNG
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/ini1.json',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                        Image.asset(
                          imagenMujer,
                          width: 200,
                          height: 200,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_floatingAnimation.value),
                        child: Text(
                          'CEREBRILLO',
                          style: const TextStyle(
                            fontSize: 42,
                            fontFamily: 'Bentham',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),

                  _GradientWaveButton(
                    text: "Iniciar sesión",
                    width: screenWidth * 0.7,
                    colors: buttonLoginColors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage(onThemeChanged: (bool isDark) {  },)),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _GradientWaveButton(
                    text: "Registrarse",
                    width: screenWidth * 0.7,
                    colors: buttonRegisterColors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage(onThemeChanged: (bool isDark) {  },)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientWaveButton extends StatefulWidget {
  final String text;
  final double width;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GradientWaveButton({
    required this.text,
    required this.width,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_GradientWaveButton> createState() => _GradientWaveButtonState();
}

class _GradientWaveButtonState extends State<_GradientWaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale,
            child: Container(
              width: widget.width,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: widget.colors,
                  stops: [
                    (_waveAnimation.value - 0.3).clamp(0.0, 1.0),
                    (_waveAnimation.value).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors[0].withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(-5, 0),
                  ),
                  BoxShadow(
                    color: widget.colors[1].withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
