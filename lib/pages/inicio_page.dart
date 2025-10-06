//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA

// ignore_for_file: deprecated_member_use 


import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart';

class InicioPage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const InicioPage({super.key, required this.onThemeChanged});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with TickerProviderStateMixin {
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;

  late AnimationController _buttonScaleController;

  bool _isDark = false;

  @override
  void initState() {
    super.initState();

    _borderController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _borderAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_borderController);

    _buttonScaleController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.05);

    _logUserAccess();
  }

  @override
  void dispose() {
    _borderController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  Future<void> _logUserAccess() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        await userRef.set({
          'lastAccess': FieldValue.serverTimestamp(),
          'email': user.email ?? '',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("❌ Error guardando acceso en Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fondo = _isDark ? "assets/images/fondo00dark.jpg" : "assets/images/fondo00.jpg";
    final String imagenMujer = _isDark ? "assets/images/mujerdark.png" : "assets/images/mujer.png";

    final List<Color> botonColores = _isDark
        ? [
            const Color.fromARGB(255, 16, 25, 159),
            const Color.fromARGB(255, 37, 37, 37),
            const Color.fromARGB(200, 15, 41, 156),
            const Color.fromARGB(255, 54, 54, 54),
          ]
        : [
            const Color.fromARGB(255, 255, 147, 183),
            const Color.fromARGB(255, 243, 208, 225),
            const Color.fromARGB(255, 255, 161, 206),
            const Color.fromARGB(255, 255, 213, 237),
          ];

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Fondo según tema
          Positioned.fill(
            child: Image.asset(
              fondo,
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Switch de tema arriba derecha
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(
                    _isDark ? Icons.nights_stay : Icons.wb_sunny,
                    color: Colors.white,
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

          // 📌 Contenido central
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Text(
                          "CEREBRILLO",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Bentham",
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1
                              ..color = Colors.white,
                          ),
                        ),
                        const Text(
                          "CEREBRILLO",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Bentham",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0.5),
                    const Text(
                      "tu gemelo virtual",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: "Bentham",
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      "assets/animations/ini1.json",
                      height: 300,
                      repeat: true,
                    ),
                    Image.asset(
                      imagenMujer,
                      height: _isDark ? 250 : 320, // 🔹 Más pequeña en dark theme
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Un compañero virtual que convierte tus desafíos escolares en logros",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Bentham",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botón holográfico abajo
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: GestureDetector(
                onTapDown: (_) => _buttonScaleController.forward(),
                onTapUp: (_) {
                  _buttonScaleController.reverse();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WelcomePage(
                        onThemeChanged: (bool isDark) {},
                      ),
                    ),
                  );
                },
                onTapCancel: () => _buttonScaleController.reverse(),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_borderAnimation, _buttonScaleController]),
                  builder: (context, child) {
                    final scale = 1 - _buttonScaleController.value;
                    return Transform.scale(
                      scale: scale,
                      child: _buildHolographicButton(
                        text: "COMENZAR",
                        colors: botonColores,
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Bentham',
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolographicButton({
    required String text,
    required List<Color> colors,
    required TextStyle textStyle,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          constraints: const BoxConstraints(
            minWidth: 160,
            maxWidth: 220,
            minHeight: 50,
            maxHeight: 60,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Color.lerp(colors[0], colors[1], _borderAnimation.value)!,
                Color.lerp(colors[2], colors[3], _borderAnimation.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(
                _borderAnimation.value * 2 * 3.14159,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(-2, -2),
              ),
              BoxShadow(
                color: colors.last.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        );
      },
    );
  }
}
