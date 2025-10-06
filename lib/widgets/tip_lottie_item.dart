import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/tip_model.dart';

class TipLottieItem extends StatelessWidget {
  final TipModel tip;
  final double scale;
  final VoidCallback onTap;

  const TipLottieItem({
    super.key,
    required this.tip,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ancho variable según scale; mantenemos altura fija relativa
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: 'hero_${tip.id}',
              child: FractionallySizedBox(
                widthFactor: 0.85 * scale,
                heightFactor: 0.85 * scale,
                child: Lottie.asset(
                  tip.lottieMain,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Bentham',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            tip.subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
