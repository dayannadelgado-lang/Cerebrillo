import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// Import oficial de la librería


class LottieButton extends StatelessWidget {
  final String lottieAsset;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final String? label; // Nuevo parámetro opcional para el texto

  const LottieButton({
    super.key,
    required this.lottieAsset,
    required this.onPressed,
    this.width = 80,
    this.height = 80,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            lottieAsset,
            width: width,
            height: height,
            repeat: false,
          ),
          if (label != null) ...[
            const SizedBox(height: 8),
            Text(
              label!,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

