//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA


// lib/pages/diary_page.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'note_editor_page.dart';
import 'diary_history_page.dart';
import 'welcome_page.dart';

class DiaryPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const DiaryPage({super.key, required this.onThemeChanged, required String userPassword});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> with TickerProviderStateMixin {
  String? selectedEmotion;
  List<String> selectedFeelings = [];
  late AnimationController _vibrationController;
  late Animation<double> _vibrationAnimation;
  late AnimationController _buttonScaleController;
  late Animation<double> _borderAnimation;
  late AnimationController _holoAnimationController;
  bool _isDark = false;

  final List<String> emotions = [
    'assets/images/asco.png',
    'assets/images/enojo.png',
    'assets/images/felicidad.png',
    'assets/images/miedo.png',
    'assets/images/sorpresa.png',
    'assets/images/tristeza.png',
  ];

  final List<String> feelings = [
    'assets/images/ansiedad.png',
    'assets/images/alegria.png',
    'assets/images/depresion.png',
    'assets/images/distraido.png',
    'assets/images/furia.png',
    'assets/images/insomnio.png',
  ];

  @override
  void initState() {
    super.initState();
    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _vibrationAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _vibrationController, curve: Curves.easeInOut),
    );

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeInOut),
    );

    _holoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _vibrationController.dispose();
    _buttonScaleController.dispose();
    _holoAnimationController.dispose();
    super.dispose();
  }

  Future<void> _saveDaySelection() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('diario')
            .add({
          'fecha': DateTime.now(),
          'emocion': selectedEmotion,
          'sentimientos': selectedFeelings,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Diario guardado correctamente")),
      );
    } catch (e) {
      debugPrint("❌ Error guardando selección en Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al guardar diario")),
      );
    }
  }

  Widget _buildSelectionIcon(bool isSelected) {
    if (!isSelected) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: _isDark ? Colors.black : Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.check,
          size: 18,
          color: _isDark ? Colors.blue : const Color.fromARGB(255, 255, 105, 165),
        ),
      ),
    );
  }

  Widget _buildFeelingImage(String path, bool isSelected) {
    return Stack(
      children: [
        Center(child: Image.asset(path, fit: BoxFit.contain, height: 100)),
        _buildSelectionIcon(isSelected),
      ],
    );
  }

  Widget _buildEmotionImage(String path, bool isSelected) {
    return Stack(
      children: [
        Image.asset(path, fit: BoxFit.contain, height: 90),
        _buildSelectionIcon(isSelected),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _isDark ? "assets/images/fondodiario_dark.jpg" : "assets/images/fondodiario1.jpg",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Switch de tema (sun & moon)
                  Align(
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
                  const SizedBox(height: 175.5), // 🔺 subido un poquito
                  Text(
                    "Selecciona la emoción principal del día de hoy:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : Colors.black87, // 🔹 textos blancos en dark
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _vibrationAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_vibrationAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: CarouselSlider.builder(
                      itemCount: emotions.length,
                      options: CarouselOptions(
                        height: 110,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        enableInfiniteScroll: true,
                        viewportFraction: 0.35,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final emotion = emotions[index];
                        final isSelected = selectedEmotion == emotion;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedEmotion = emotion;
                            });
                          },
                          child: _buildEmotionImage(emotion, isSelected),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Selecciona los sentimientos principales del día de hoy:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : Colors.black87, // 🔹 textos blancos en dark
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    itemCount: feelings.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final feeling = feelings[index];
                      final isSelected = selectedFeelings.contains(feeling);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedFeelings.remove(feeling);
                            } else {
                              selectedFeelings.add(feeling);
                            }
                          });
                        },
                        child: _buildFeelingImage(feeling, isSelected),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // 🔘 Botón holográfico animado (dark theme azul/negro)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.5), // 🔺 subido un poquito
                      child: GestureDetector(
                        onTapDown: (_) => _buttonScaleController.forward(),
                        onTapUp: (_) {
                          _buttonScaleController.reverse();
                          if (selectedEmotion != null && selectedFeelings.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditorPage(
                                  selectedEmotion: selectedEmotion,
                                  selectedFeelings: List.from(selectedFeelings),
                                  isDarkTheme: _isDark,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Selecciona al menos una emoción y un sentimiento"),
                              ),
                            );
                          }
                        },
                        onTapCancel: () => _buttonScaleController.reverse(),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_borderAnimation, _buttonScaleController, _holoAnimationController]),
                          builder: (context, child) {
                            final scale = 1 - _buttonScaleController.value;
                            return Transform.scale(
                              scale: scale,
                              child: _buildHolographicButton(
                                text: "Añadir Nota",
                                colors: _isDark
                                    ? const [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0B3D91), Color(0xFF0D47A1)]
                                    : const [
                                        Color.fromARGB(255, 214, 203, 243),
                                        Color.fromARGB(255, 243, 208, 225),
                                        Color.fromARGB(255, 214, 207, 255),
                                        Color.fromARGB(255, 255, 213, 237),
                                      ],
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontFamily: 'Bentham',
                                  color: Colors.white,
                                ),
                                holoValue: _holoAnimationController.value,
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
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
    required double holoValue,
    required VoidCallback onTap,
  }) {
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
            Color.lerp(colors[0], colors[1], holoValue)!,
            Color.lerp(colors[2], colors[3], holoValue)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(holoValue * 2 * 3.14159),
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
        child: Text(text, style: textStyle),
      ),
    );
  }
}
