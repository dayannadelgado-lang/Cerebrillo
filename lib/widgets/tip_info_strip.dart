import 'package:flutter/material.dart';

class TipInfoStrip extends StatelessWidget {
  final String title;
  final String body;

  const TipInfoStrip({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Montserrat')),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
