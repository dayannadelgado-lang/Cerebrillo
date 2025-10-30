// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cerebrillo1/pages/home_page.dart';
import 'package:cerebrillo1/ar_marker_ml_screen.dart';
import 'package:cerebrillo1/ar_native_screen.dart';
import 'package:cerebrillo1/ar_viewer_screen.dart';

class ARPage extends StatefulWidget {
  const ARPage({super.key});

  @override
  State<ARPage> createState() => _ARPageState();
}

class _ARPageState extends State<ARPage> with TickerProviderStateMixin {
  late AnimationController _borderController;
  late AnimationController _tapAnimationController;
  late AnimationController _titleMovementController;
  late AnimationController _menuZoomController;

  int _selectedBottomIndex = 2;

  @override
  void initState() {
    super.initState();

    _borderController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);

    _tapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _titleMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _menuZoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _borderController.dispose();
    _tapAnimationController.dispose();
    _titleMovementController.dispose();
    _menuZoomController.dispose();
    super.dispose();
  }

  void _onMenuTap(int index) {
    setState(() => _selectedBottomIndex = index);
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(onThemeChanged: (bool value) {}),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ARPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color pastelPink = const Color(0xFFF9D1E0);
    final Color pastelPurple = const Color(0xFFD5C4F2);
    final Color pastelBlue = const Color(0xFFBFE0F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// 🌄 Fondo con imagen
          SizedBox.expand(
            child: Image.asset(
              "assets/images/fondologro1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                /// 🔝 Header con título animado
                Positioned(
                  top: 18,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔙 Botón regresar
                      Container(
                        decoration: BoxDecoration(
                          color: pastelBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: pastelBlue.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HomePage(onThemeChanged: (bool value) {}),
                              ),
                            );
                          },
                        ),
                      ),

                      // ✨ Título con movimiento oscilante
                      AnimatedBuilder(
                        animation: _titleMovementController,
                        builder: (context, child) {
                          double dx = math.sin(_titleMovementController.value * 2 * math.pi) * 10;
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: const Text(
                              "AR - CEREBRILLO",
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black,
                                letterSpacing: 1.2,
                              ),
                            ),
                          );
                        },
                      ),

                      // 💙 Botón favoritos
                      Container(
                        decoration: BoxDecoration(
                          color: pastelBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: pastelBlue.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border_rounded,
                              color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Próximamente tus modelos favoritos 💗",
                                  textAlign: TextAlign.center,
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🧠 Widgets AR
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildARWidget(
                          title: "Visor Cerebro 3D",
                          icon: Icons.public,
                          baseColors: [pastelPink, pastelPurple],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ARViewerScreen(
                                  modelUrl:
                                      "https://modelviewer.dev/shared-assets/models/BrainStem.glb",
                                  iosModelUrl:
                                      "https://modelviewer.dev/shared-assets/models/BrainStem.usdz",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        _buildARWidget(
                          title: "Escáner de Marcador",
                          icon: Icons.document_scanner_outlined,
                          baseColors: [pastelPurple, pastelBlue],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ARMarkerMLScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        _buildARWidget(
                          title: "RA Nativa (ARCore / ARKit)",
                          icon: Icons.view_in_ar,
                          baseColors: [pastelBlue, pastelPink],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ARNativeScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// 🔻 Menú inferior animado
      bottomNavigationBar: AnimatedBuilder(
        animation: _menuZoomController,
        builder: (context, child) {
          double zoom = 1 + 0.15 * math.sin(_menuZoomController.value * 2 * math.pi);
          return Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMenuItem(Icons.home, 0),
                _buildMenuItem(Icons.chat, 1),
                Transform.scale(
                  scale: zoom,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [pastelBlue, pastelPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pastelBlue.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.view_in_ar,
                        color: Colors.white, size: 36),
                  ),
                ),
                _buildMenuItem(Icons.favorite, 3),
                _buildMenuItem(Icons.settings, 4),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, int index) {
    final isSelected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () => _onMenuTap(index),
      child: Icon(
        icon,
        color: isSelected ? const Color(0xFFBFE0F9) : Colors.grey[400],
        size: isSelected ? 30 : 26,
      ),
    );
  }

  /// 🎨 Widget AR (sin blanco en los gradientes)
  Widget _buildARWidget({
    required String title,
    required IconData icon,
    required List<Color> baseColors,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        final t = _borderController.value;
        final animatedColors = [
          Color.lerp(baseColors[0], baseColors[1], (math.sin(t * 2 * math.pi) + 1) / 2)!,
          Color.lerp(baseColors[1], baseColors[0], (math.cos(t * 2 * math.pi) + 1) / 2)!,
        ];

        return GestureDetector(
          onTapDown: (_) => _tapAnimationController.forward(),
          onTapUp: (_) async {
            _tapAnimationController.reverse();
            await Future.delayed(const Duration(milliseconds: 150));
            onPressed();
          },
          child: Transform.scale(
            scale: 1 - _tapAnimationController.value,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: animatedColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: animatedColors.last.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  Icon(icon, color: Colors.white, size: 42),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat",
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
