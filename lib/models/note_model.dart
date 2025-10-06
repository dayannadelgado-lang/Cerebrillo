import 'package:flutter/material.dart';
import '../utils/colors.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageAsset;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.imageAsset,
  });


  Note copyWith({
    String? title,
    String? content,
    String? imageAsset,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  Widget styledCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )),
            const SizedBox(height: 8),
            Text(content,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.black87,
                )),
            if (imageAsset != null) ...[
              const SizedBox(height: 12),
              Image.asset(imageAsset!, fit: BoxFit.cover),
            ]
          ],
        ),
      ),
    );
  }
}
