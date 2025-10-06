//ACA AGREGARAN EL CHATBOT Y MODIFICARAN EL DISEÑO



import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IAHomePage extends StatelessWidget {
  const IAHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inteligencia Artificial"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 171, 235),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Aquí puedes agregar la acción de la IA
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("IA activada 🚀")),
            );
          },
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animación
                Lottie.asset(
                  'assets/animations/cerebrolupa.json',
                  width: 150,
                  height: 150,
                  repeat: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Presiona para activar la IA",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 127, 178),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
