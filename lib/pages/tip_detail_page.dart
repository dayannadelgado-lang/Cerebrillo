// SE QUEDA COMO ESTA 

// lib/pages/tip_detail_page.dart
import 'package:flutter/material.dart';
import '../models/tip_model.dart';
import 'package:lottie/lottie.dart';

class TipDetailPage extends StatelessWidget {
  final TipModel tip;
  final List<TipModel> allTips;

  const TipDetailPage({super.key, required this.tip, required this.allTips});

  Color _colorForTip(String id) {
    switch (id) {
      case "pomodoro": return const Color.fromARGB(255, 255, 191, 221);
      case "mapas": return const Color.fromARGB(255, 206, 194, 255);
      case "flashcards": return const Color.fromARGB(255, 209, 231, 237);
      case "resumenes": return const Color.fromARGB(255, 255, 214, 232);
      case "lectura": return const Color.fromARGB(255, 255, 231, 244);
      case "vozalta": return const Color.fromARGB(255, 224, 234, 243);
      case "planificacion": return const Color.fromARGB(255, 236, 211, 243);
      default: return Colors.white;
    }
  }

  LinearGradient _gradientTextForTip(String id) {
    switch (id) {
      case "pomodoro": return const LinearGradient(colors: [Color.fromARGB(255, 245, 208, 228), Color.fromARGB(255, 255, 153, 209)]);
      case "mapas": return const LinearGradient(colors: [Color.fromARGB(255, 206, 223, 255), Color.fromARGB(255, 179, 196, 247)]);
      case "flashcards": return const LinearGradient(colors: [Color.fromARGB(255, 202, 233, 237), Color.fromARGB(255, 187, 224, 220)]);
      case "resumenes": return const LinearGradient(colors: [Color.fromARGB(255, 255, 148, 196), Color.fromARGB(255, 255, 203, 220)]);
      case "lectura": return const LinearGradient(colors: [Color.fromARGB(255, 255, 224, 234), Color.fromARGB(255, 238, 199, 245)]);
      case "vozalta": return const LinearGradient(colors: [Color.fromARGB(255, 209, 223, 224), Color.fromARGB(255, 226, 239, 250)]);
      case "planificacion": return const LinearGradient(colors: [Color.fromARGB(255, 230, 212, 233), Color.fromARGB(255, 207, 196, 238)]);
      default: return const LinearGradient(colors: [Colors.white, Colors.white]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tip.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          /// 🔹 Lottie tipG arriba
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35,
            child: Lottie.asset(
              "assets/animations/tipG.json",
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),

          /// 🔹 Lottie tipG volteado abajo (cubriendo bien el borde)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: 3.1416,
              child: Lottie.asset(
                "assets/animations/tipG.json",
                width: MediaQuery.of(context).size.width,
                height: screenHeight * 0.4, // un poco más alto para cubrir
                fit: BoxFit.cover, // cubre completo
                repeat: true,
              ),
            ),
          ),

          /// 🔹 Contenido
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 54),

                    // Título con gradiente
                    Text(
                      tip.title,
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = _gradientTextForTip(tip.id).createShader(
                            const Rect.fromLTWH(0, 0, 200, 100),
                          ),
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: _colorForTip(tip.id),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 74),

                    // Imagen principal con overlay Lottie
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(tip.lottieMain, height: 300, fit: BoxFit.contain),
                        if ((tip.lottieOverlay ?? "").isNotEmpty)
                          Lottie.asset(
                            tip.lottieOverlay ?? "",
                            width: 300,
                            height: 300,
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      tip.subtitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Detalles:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tip.details
                          .map((detail) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "- $detail",
                                  style: const TextStyle(fontSize: 16, color: Colors.black), // reducido
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
