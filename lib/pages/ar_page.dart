import 'package:flutter/material.dart';
// ignore: unused_import
import '../utils/colors.dart';

class ARPage extends StatelessWidget {
  const ARPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Cerebrillo'),
        backgroundColor: const Color.fromARGB(255, 255, 136, 182),
      ),
      body: const Center(
        child: Text(
          'Sección de realidad aumentada',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
