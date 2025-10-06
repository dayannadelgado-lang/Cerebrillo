import 'package:flutter/material.dart';
import '../utils/colors.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final int streak; // días consecutivos completados
  final bool isCompletedToday;
  final String lottieAsset;

  const Habit({
    required this.id,
    required this.name,
    required this.description,
    this.streak = 0,
    this.isCompletedToday = false,
    this.lottieAsset = 'assets/animations/corazon.json',
  });

  Habit copyWith({
    String? name,
    String? description,
    int? streak,
    bool? isCompletedToday,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      streak: streak ?? this.streak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lottieAsset: lottieAsset,
    );
  }

  Widget styledCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: Image.asset(lottieAsset), // usar Lottie.asset si es Lottie
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      )),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 4),
                  Text('Racha: $streak días',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Colors.grey,
                      )),
                ],
              ),
            ),
            Checkbox(
              value: isCompletedToday,
              onChanged: (val) {},
              activeColor: AppColors.accent,
            )
          ],
        ),
      ),
    );
  }
}
