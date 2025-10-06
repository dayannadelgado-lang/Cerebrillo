// ESTA PAGINA SE QUEDA COMO ESTA ENTONCES NO LA TOQUEN




// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class SurveyPage extends StatefulWidget {
  final void Function(List<int>) onSurveyComplete;

  const SurveyPage({super.key, required this.onSurveyComplete});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  int selectedOption = -1;
  final List<int> answers = [];

  late AnimationController _popupController;
  late PageController _optionController;

  final List<String> questions = [
    "¿Cómo aprendes mejor nueva información?",
    "¿Qué actividad disfrutas más en tu tiempo libre?",
    "¿Qué tipo de retos prefieres?",
    "¿Cómo prefieres trabajar?",
    "¿Qué te motiva más a seguir?"
  ];

  final List<List<Map<String, String>>> options = [
    [
      {"text": "Escuchando", "image": "assets/images/oido.png"},
      {"text": "Leyendo", "image": "assets/images/libros.png"},
      {"text": "Practicando", "image": "assets/images/experimentos.png"},
    ],
    [
      {"text": "Deporte", "image": "assets/images/deporte.png"},
      {"text": "Arte", "image": "assets/images/arte.png"},
      {"text": "Juegos", "image": "assets/images/juegos.png"},
    ],
    [
      {"text": "Físicos", "image": "assets/images/fisico.png"},
      {"text": "Mentales", "image": "assets/images/mental.png"},
      {"text": "Sociales", "image": "assets/images/social.png"},
    ],
    [
      {"text": "Solo", "image": "assets/images/individual.png"},
      {"text": "En equipo", "image": "assets/images/equipo.png"},
      {"text": "Mixto", "image": "assets/images/mixtoequipo.png"},
    ],
    [
      {"text": "Reconocimiento", "image": "assets/images/reconocimiento.png"},
      {"text": "Logros", "image": "assets/images/logros.png"},
      {"text": "Diversión", "image": "assets/images/diversion.png"},
    ],
  ];

  final List<String> questionImages = [
    "assets/images/E1.png",
    "assets/images/E2.png",
    "assets/images/E3.png",
    "assets/images/E4.png",
    "assets/images/E5.png",
  ];

  final List<String> backgroundImages = [
    "assets/images/fondoen1.jpg",
    "assets/images/fondoen2.jpg",
    "assets/images/fondoen3.jpg",
    "assets/images/fondoen4.jpg",
    "assets/images/fondoen5.jpg",
  ];

  final List<Color> circleColors = [
    const Color.fromARGB(220, 199, 233, 242),
    const Color.fromARGB(255, 195, 234, 251),
    const Color.fromARGB(255, 255, 196, 228),
    const Color.fromARGB(255, 255, 188, 215),
    const Color.fromARGB(255, 183, 197, 254),
  ];

  final List<Color> optionNeonColors = [
    const Color.fromARGB(255, 147, 213, 254),
    const Color.fromARGB(255, 155, 201, 224),
    const Color.fromARGB(255, 255, 193, 227),
    const Color.fromARGB(255, 255, 145, 162),
    const Color.fromARGB(255, 193, 184, 241),
  ];

  @override
  void initState() {
    super.initState();
    _popupController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _optionController = PageController(viewportFraction: 0.6, initialPage: 1000);
  }

  @override
  void dispose() {
    _popupController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Container(
              key: ValueKey<int>(currentQuestion),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImages[currentQuestion]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      height: 250,
                      color: circleColors[currentQuestion],
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    child: Image.asset(
                      questionImages[currentQuestion],
                      height: 240,
                    ),
                  ),
                  const Positioned(
                    top: 60,
                    child: Text(
                      "Selecciona tu respuesta",
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    questions[currentQuestion],
                    key: ValueKey<int>(currentQuestion),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _optionController,
                  itemBuilder: (context, oIndex) {
                    final realIndex =
                        oIndex % options[currentQuestion].length;
                    return AnimatedBuilder(
                      animation: _optionController,
                      builder: (context, child) {
                        double value = 0.0;
                        if (_optionController.position.haveDimensions) {
                          value = _optionController.page! - oIndex;
                          value = (value * 0.5).clamp(-1, 1);
                        }
                        double scale = 1 - (value.abs() * 0.3);
                        double angle = value * 0.3;
                        return Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: angle,
                            child: Opacity(
                              opacity: (1 - value.abs()).clamp(0.4, 1.0)
                                  .toDouble(),
                              child: _buildOptionCard(
                                  text: options[currentQuestion][realIndex]
                                      ["text"]!,
                                  image: options[currentQuestion][realIndex]
                                      ["image"]!,
                                  isSelected: selectedOption == realIndex,
                                  onTap: () {
                                    setState(() {
                                      selectedOption = realIndex;
                                    });
                                  }),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                  ),
                  onPressed: selectedOption != -1
                      ? () async {
                          answers.add(selectedOption);
                          if (currentQuestion < questions.length - 1) {
                            setState(() {
                              currentQuestion++;
                              selectedOption = -1;
                            });
                            _optionController.jumpToPage(1000);
                          } else {
                            // Terminar encuesta
                            await _showAnalysisAndRegistered();
                          }
                        }
                      : null,
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
      {required String text,
      required String image,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: optionNeonColors[currentQuestion].withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 4)
                ]
              : [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4))
                ],
          border: isSelected
              ? Border.all(color: optionNeonColors[currentQuestion], width: 3)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 160),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 18,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAnalysisAndRegistered() async {
    int aCount = answers.where((a) => a == 1).length;
    int bCount = answers.where((a) => a == 2).length;
    int cCount = answers.where((a) => a == 0).length;

    String profile, tips, pros, cons, improve;

    if (aCount >= bCount && aCount >= cCount) {
      profile = "Analítico / Reflexivo";
      tips = "Haz resúmenes, esquemas y estudia con horarios.";
      pros = "Organizado, concentrado y con buena retención teórica.";
      cons = "Rigidez, lentitud y frustración si no hay estructura.";
      improve = "Agrega práctica e interacción social.";
    } else if (bCount >= aCount && bCount >= cCount) {
      profile = "Práctico / Kinestésico";
      tips = "Haz ejercicios, usa Pomodoro y estudia con práctica.";
      pros = "Flexible, aprende rápido haciendo.";
      cons = "Dificultad con teoría larga, dispersión.";
      improve = "Agrega resúmenes escritos y algo de estructura.";
    } else {
      profile = "Social / Visual / Auditivo";
      tips = "Usa videos, mapas, debates y enseña a otros.";
      pros = "Motivado, creativo, retiene con interacción.";
      cons = "Difícil concentrarse solo, puede memorizar superficial.";
      improve = "Integra estudio individual y escritura.";
    }

    // Mostrar análisis
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(profile,
            style:
                const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("✅ Tips: $tips"),
            Text("⭐ Pros: $pros"),
            Text("⚠️ Contras: $cons"),
            Text("📈 Mejora: $improve"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Continuar"))
        ],
      ),
    );

    // Guardar en Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'surveyAnswers': answers,
        'surveyCompletedAt': FieldValue.serverTimestamp(),
      });
    }

    // Mostrar popup registrado
    _popupController.forward(from: 0);
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return ScaleTransition(
            scale:
                CurvedAnimation(parent: _popupController, curve: Curves.elasticOut),
            child: FadeTransition(
              opacity: _popupController,
              child: Dialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color.fromARGB(255, 255, 166, 203), size: 60),
                      const SizedBox(height: 10),
                      const Text(
                        "REGISTRADO",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Montserrat"),
                      ),
                      const Divider(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HomePage(onThemeChanged: (bool isDark) {  },)));
                        },
                        child: const Text(
                          "Continuar",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });

    widget.onSurveyComplete(answers);
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
