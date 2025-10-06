//TAMPOCO TOQUEN ESRA PAGINA 


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyResultPage extends StatelessWidget {
  final List<String> answers;

  const SurveyResultPage({super.key, required this.answers});

  Map<String, dynamic> analyzeAnswers() {
    int aCount = answers.where((x) => x == "A").length;
    int bCount = answers.where((x) => x == "B").length;
    int cCount = answers.where((x) => x == "C").length;

    String profile;
    String tips;
    String pros;
    String cons;
    String improve;

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

    return {
      "profile": profile,
      "tips": tips,
      "pros": pros,
      "cons": cons,
      "improve": improve,
    };
  }

  Widget buildCard({required IconData icon, required String title, required String content, Color? color}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color ?? Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "LuckiestGuy",
                      fontSize: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveResultsToFirestore(Map<String, dynamic> result) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'surveyResult': result,
        'surveyResultAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = analyzeAnswers();

    // Guardar automáticamente los resultados en Firestore
    saveResultsToFirestore(result);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultado"),
        backgroundColor: const Color(0xFF6A0572),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Tu perfil de estudio es:",
              style: TextStyle(
                fontFamily: "LuckiestGuy",
                fontSize: 24,
                color: Color(0xFF6A0572),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result["profile"],
              style: const TextStyle(
                fontFamily: "LuckiestGuy",
                fontSize: 28,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            buildCard(
              icon: Icons.lightbulb_outline,
              title: "Tips",
              content: result["tips"],
              color: Colors.purple[50],
            ),
            buildCard(
              icon: Icons.star_outline,
              title: "Ventajas",
              content: result["pros"],
              color: Colors.green[50],
            ),
            buildCard(
              icon: Icons.warning_amber_outlined,
              title: "Desventajas",
              content: result["cons"],
              color: Colors.red[50],
            ),
            buildCard(
              icon: Icons.check_circle_outline,
              title: "Qué mejorar",
              content: result["improve"],
              color: Colors.blue[50],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A0572),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                "Volver a la encuesta",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
