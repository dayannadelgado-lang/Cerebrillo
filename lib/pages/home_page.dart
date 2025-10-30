// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_local_variable, prefer_final_fields

import 'package:cerebrillo1/pages/meditacion_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tips_page.dart';
import 'diary_page.dart';
import 'logros_page.dart';
import 'survey_page.dart';
import 'settings_page.dart';
import 'chatbot_page.dart';
import 'ar_page.dart'; // 🔹 Importar ARPage
import 'pendientes_page.dart'; // 🔹 Importar PendientesPage
import 'tasks_page.dart'; // 🔹 Importar TasksPage
import '../models/tip_model.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onThemeChanged});
  final void Function(bool isDark) onThemeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  int _tappedIndex = -1;
  bool _isDark = false;
  final Color azulDark = const Color.fromARGB(255, 38, 27, 154);

  int _selectedBottomIndex = 0;

  late AnimationController _gradientController;
  late AnimationController _iconBounceController;
  late AnimationController _holoRotateController;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserData();

    _gradientController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    _iconBounceController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _holoRotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _iconBounceController.dispose();
    _holoRotateController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists) {
        setState(() => _userData = doc.data());
        final surveyDone = _userData?['survey_done'] ?? false;
        if (!surveyDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SurveyPage(
                  onSurveyComplete: (List<int> answers) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(_currentUser!.uid)
                        .set({
                      'survey_done': true,
                      'survey_answers': answers,
                      'timestamp': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TipsPage(
                          perfil: _userData?['name'] ?? 'Usuario',
                          tips: _generateTipsFromSurvey(answers),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          });
        }
      }
    }
  }

  List<TipModel> _generateTipsFromSurvey(List<int> answers) {
    return answers
        .map((a) => TipModel(
              id: 'tip$a',
              title: 'Tip $a',
              subtitle: 'Tip basado en respuesta $a',
              lottieMain: 'assets/images/pomodoro.png',
              lottieOverlay: '',
              details: ['Detalle 1', 'Detalle 2'],
              imagePath: '',
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userData?['name'] ?? "Usuario";
    final String fondo =
        _isDark ? "assets/images/home_darl.jpg" : "assets/images/home2.jpg";

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset(fondo, fit: BoxFit.cover)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset("assets/animations/ini1.json",
                          width: 160, height: 160, repeat: true),
                      Lottie.asset("assets/animations/meditacion.json",
                          width: 120, height: 120, repeat: true),
                      Image.asset('assets/images/mujer.png', height: 0),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hola, $userName",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "CREE",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat",
                        color: Colors.white),
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.white70,
                    indent: 80,
                    endIndent: 80,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Confía en ti, porque la persona capaz de lograrlo ya vive dentro de ti.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, fontFamily: "Bentham", color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildAnimatedOption(
                          index: 0,
                          icon: Icons.lightbulb_outline,
                          label: "TIPS",
                          page: TipsPage(
                            perfil: userName,
                            tips: _userData?['survey_answers'] != null
                                ? _generateTipsFromSurvey(
                                    List<int>.from(_userData!['survey_answers']))
                                : [],
                          ),
                          circleColor: _isDark
                              ? azulDark
                              : const Color.fromARGB(255, 255, 223, 245),
                        ),
                        _buildAnimatedOption(
                          index: 1,
                          icon: Icons.menu_book,
                          label: "DIARIO",
                          page: DiaryPage(
                              userPassword: "", onThemeChanged: (bool p1) {}),
                          circleColor: _isDark
                              ? azulDark
                              : const Color.fromARGB(255, 255, 223, 245),
                        ),
                        _buildAnimatedOption(
                          index: 2,
                          icon: Icons.favorite,
                          label: "MEDITACION",
                          page: const MeditacionPage(),
                          circleColor: _isDark
                              ? azulDark
                              : const Color.fromARGB(255, 255, 223, 245),
                        ),
                        _buildAnimatedOption(
                          index: 3,
                          icon: Icons.emoji_events,
                          label: "LOGROS",
                          page: const LogrosPage(),
                          circleColor: _isDark
                              ? azulDark
                              : const Color.fromARGB(255, 255, 223, 245),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChatBotPage()));
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              colors: [
                                Color.lerp(const Color(0xFFE0B3FF),
                                    const Color(0xFFFFB3C1), _gradientController.value)!,
                                Color.lerp(const Color(0xFFFFB3C1),
                                    const Color(0xFFB3D9FF), _gradientController.value)!,
                                Color.lerp(const Color(0xFFB3D9FF),
                                    const Color(0xFFE0B3FF), _gradientController.value)!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white.withOpacity(0.9),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4))
                            ],
                            border: Border.all(
                                color: Colors.white.withOpacity(0.9), width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              "CEREBRILLO IA",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Montserrat"),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            IconData icon;
            String label;
            switch (index) {
              case 0:
                icon = Icons.task;
                label = "Habitos";
                break;
              case 1:
                icon = Icons.notifications;
                label = "Recordatorios";
                break;
              case 2:
                icon = Icons.check_box;
                label = "Tareas";
                break;
              case 3:
                icon = Icons.pending;
                label = "Pendientes";
                break;
              default:
                icon = Icons.view_in_ar; // 🔹 Icono AR
                label = "AR"; // 🔹 Texto AR
            }
            return GestureDetector(
              onTap: () {
                setState(() => _selectedBottomIndex = index);
                _iconBounceController.forward(from: 0);

                // 🔹 Navegación correcta para Tareas, Pendientes y AR
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TasksPage()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PendientesPage()),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ARPage()),
                  );
                }
              },
              child: AnimatedBuilder(
                animation: Listenable.merge([_iconBounceController, _holoRotateController]),
                builder: (context, child) {
                  double bounce = _selectedBottomIndex == index
                      ? 1 + 0.3 * _iconBounceController.value
                      : 1.0;
                  double rotation = _selectedBottomIndex == index
                      ? _holoRotateController.value * 2 * math.pi
                      : 0.0;

                  return Transform.scale(
                    scale: bounce,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedBottomIndex == index)
                          Transform.rotate(
                            angle: rotation,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: SweepGradient(
                                  colors: [
                                    Colors.pinkAccent.shade100.withOpacity(0.5),
                                    Colors.purpleAccent.shade100.withOpacity(0.5),
                                    Colors.pinkAccent.shade100.withOpacity(0.5),
                                  ],
                                  startAngle: 0.0,
                                  endAngle: 6.3,
                                ),
                              ),
                            ),
                          ),
                        Icon(icon,
                            color: _selectedBottomIndex == index
                                ? Colors.white
                                : Colors.white70,
                            size: 28),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAnimatedOption({
    required int index,
    required IconData icon,
    required String label,
    required Widget page,
    required Color circleColor,
  }) {
    final isTapped = _tappedIndex == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _tappedIndex = index),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          setState(() => _tappedIndex = -1);
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        });
      },
      onTapCancel: () => setState(() => _tappedIndex = -1),
      child: AnimatedScale(
        scale: isTapped ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isDark
                ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isTapped ? circleColor.withOpacity(0.4) : Colors.white24,
                blurRadius: isTapped ? 15 : 6,
                spreadRadius: isTapped ? 3 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  color: _isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
