// SE QUEDAN COMO ESTA 


/// lib/pages/tips_page.dart
// ignore_for_file: non_constant_identifier_names, deprecated_member_use, unused_element, dangling_library_doc_comments

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tip_model.dart';
import 'home_page.dart';
import 'tip_detail_page.dart';
import 'package:lottie/lottie.dart';

class TipsPage extends StatefulWidget {
  final String perfil;
  const TipsPage({super.key, required this.perfil, required List<TipModel> tips});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _glowController;
  late AnimationController _floatController;

  final List<TipModel> _tips = [
    TipModel(
      id: "pomodoro",
      title: "Pomodoro",
      subtitle: "Divide tu tiempo en bloques",
      lottieMain: "assets/images/pomodoro.png",
      lottieOverlay: "",
      details: ["25 minutos de trabajo", "5 minutos de descanso", "Repite el ciclo"],
      imagePath: '',
    ),
    TipModel(
      id: "mapas",
      title: "Mapas Mentales",
      subtitle: "Organiza tus ideas",
      lottieMain: "assets/images/maps.png",
      lottieOverlay: "",
      details: ["Usa colores", "Conecta conceptos", "Facilita la memoria"],
      imagePath: '',
    ),
    TipModel(
      id: "flashcards",
      title: "Flash Cards",
      subtitle: "Repasa con tarjetas",
      lottieMain: "assets/images/flashcards.png",
      lottieOverlay: "",
      details: ["Pregunta y respuesta", "Memoria activa", "Práctica diaria"],
      imagePath: '',
    ),
    TipModel(
      id: "resumenes",
      title: "Resúmenes",
      subtitle: "Sintetiza lo aprendido",
      lottieMain: "assets/images/resumenes.png",
      lottieOverlay: "",
      details: ["Palabras clave", "Ideas principales", "Formato breve"],
      imagePath: '',
    ),
    TipModel(
      id: "lectura",
      title: "Lectura Activa",
      subtitle: "Comprensión profunda",
      lottieMain: "assets/images/lectura.png",
      lottieOverlay: "",
      details: ["Subraya ideas", "Haz anotaciones", "Relaciona conceptos"],
      imagePath: '',
    ),
    TipModel(
      id: "vozalta",
      title: "Explicar en Voz Alta",
      subtitle: "Refuerza con tu voz",
      lottieMain: "assets/images/vozalta.png",
      lottieOverlay: "",
      details: ["Explica como profesor", "Identifica dudas", "Mejora retención"],
      imagePath: '',
    ),
    TipModel(
      id: "planificacion",
      title: "Planificación Semanal",
      subtitle: "Organiza tu semana",
      lottieMain: "assets/images/planificacionsemanal.png",
      lottieOverlay: "",
      details: ["Asigna horarios", "Equilibra materias", "Incluye descansos"],
      imagePath: '',
    ),
  ];

  /// 🎨 Colores para los círculos de fondo
  final Map<String, Color> _circleColors = {
    "pomodoro": const Color.fromARGB(255, 255, 200, 219).withOpacity(0.20),
    "mapas": const Color.fromARGB(255, 238, 218, 211).withOpacity(0.20),
    "flashcards": const Color.fromARGB(255, 204, 227, 230).withOpacity(0.20),
    "resumenes": const Color.fromARGB(255, 216, 235, 238).withOpacity(0.20),
    "lectura": const Color.fromARGB(255, 255, 210, 225).withOpacity(0.20),
    "vozalta": const Color.fromARGB(255, 191, 227, 236).withOpacity(0.20),
    "planificacion": const Color.fromARGB(255, 223, 212, 235).withOpacity(0.20),
  };

  /// 🎨 Colores diferentes para el texto "ESTUDIO"
  final Map<String, List<Color>> _titleColors = {
    "pomodoro": [const Color.fromARGB(255, 255, 221, 232), const Color.fromARGB(131, 255, 153, 178)],
    "mapas": [const Color.fromARGB(255, 233, 214, 190), const Color.fromARGB(207, 252, 224, 187)],
    "flashcards": [const Color.fromARGB(255, 178, 210, 214), const Color.fromARGB(255, 196, 211, 216)],
    "resumenes": [const Color.fromARGB(255, 255, 205, 197), const Color.fromARGB(255, 255, 230, 224)],
    "lectura": [const Color.fromARGB(255, 252, 207, 223), const Color.fromARGB(255, 255, 230, 244)],
    "vozalta": [const Color.fromARGB(255, 181, 199, 215), const Color.fromARGB(255, 210, 224, 230)],
    "planificacion": [const Color.fromARGB(255, 192, 214, 212), const Color.fromARGB(255, 213, 227, 220)],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0, initialPage: 1000 * _tips.length);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Color _colorForTip(String id) {
    return _circleColors[id] ?? Colors.grey.withOpacity(0.2);
  }

  List<Color> _colorsForTitle(String id) {
    return _titleColors[id] ?? [Colors.white, Colors.grey];
  }

  /// Header con TIPS y ESTUDIO animado
  Widget _header() {
    return Column(
      children: [
        const Text(
          "TIPS",
          style: TextStyle(
            fontFamily: "Boogaloo",
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final colors = _colorsForTitle(_tips[_currentIndex].id);
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: colors,
                  begin: Alignment(-1 + _glowController.value * 2, 0),
                  end: Alignment(1 + _glowController.value * 2, 0),
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
              },
              child: const Text(
                "ESTUDIO",
                style: TextStyle(
                  fontFamily: "Boogaloo",
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: Colors.white,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Botones inferiores
  Widget _bottomRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.favorite, color: Color.fromARGB(255, 255, 92, 154)),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24)),
              child: const Text("AÑADIR",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HomePage(
                            onThemeChanged: (bool isDark) {},
                          )));
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.home, color: Color.fromARGB(221, 255, 255, 255)),
            ),
          ),
        ],
      ),
    );
  }

  /// Card con círculo translúcido y PNG animado
  Widget _buildTipCard(TipModel tip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TipDetailPage(tip: tip, allTips: _tips)),
        );
      },
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (_floatController.value - 0.5)),
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colorForTip(tip.id),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                tip.lottieMain,
                height: 240, // 📌 PNG más grande
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Fondo animado arriba
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35,
            child: Lottie.asset("assets/animations/tipG.json",
                fit: BoxFit.cover, repeat: true),
          ),
          /// Fondo animado abajo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35,
            child: Transform.rotate(
              angle: 3.1416,
              child: Lottie.asset("assets/animations/tipG.json",
                  fit: BoxFit.cover, repeat: true),
            ),
          ),
          /// Contenido principal
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _header(),
                const SizedBox(height: 20),
                const Text(
                  "Desliza para ver más opciones",
                  style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final current = index % _tips.length;
                      return Center(child: _buildTipCard(_tips[current]));
                    },
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index % _tips.length),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _tips[_currentIndex].title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _tips[_currentIndex].subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Montserrat",
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                _bottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
