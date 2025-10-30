import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddReviewVariables {
  String movieId;
  int rating;
  String reviewText;

  AddReviewVariables({
    required this.movieId,
    required this.rating,
    required this.reviewText,
  });

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'rating': rating,
      'reviewText': reviewText,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class AddReviewData {
  String id; // Document ID en Firestore
  AddReviewData({required this.id});
}

class AddReview {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AddReviewData> execute(AddReviewVariables vars, String userId) async {
    // Guardar el review en Firestore
    final docRef = await _firestore.collection('reviews').add({
      'userId': userId,
      'movieId': vars.movieId,
      'rating': vars.rating,
      'reviewText': vars.reviewText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return AddReviewData(id: docRef.id);
  }
}
