// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';

class ExampleConnector {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ────────────── CREATE MOVIE ──────────────
  Future<String> createMovie({
    required String title,
    required String genre,
    required String imageUrl,
  }) async {
    final docRef = await _firestore.collection('movies').add({
      'title': title,
      'genre': genre,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ────────────── UPSERT USER ──────────────
  Future<void> upsertUser({
    required String userId,
    required String username,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'username': username,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ────────────── ADD REVIEW ──────────────
  Future<String> addReview({
    required String movieId,
    required String userId,
    required int rating,
    required String reviewText,
  }) async {
    final docRef = await _firestore.collection('reviews').add({
      'movieId': movieId,
      'userId': userId,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ────────────── DELETE REVIEW ──────────────
  Future<bool> deleteReview({
    required String movieId,
    required String userId,
  }) async {
    final querySnapshot = await _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) return false;

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    return true;
  }

  // ────────────── LIST MOVIES ──────────────
  Future<List<Map<String, dynamic>>> listMovies() async {
    final snapshot = await _firestore.collection('movies').get();
    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }

  // ────────────── LIST USERS ──────────────
  Future<List<Map<String, dynamic>>> listUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }

  // ────────────── LIST USER REVIEWS ──────────────
  Future<List<Map<String, dynamic>>> listUserReviews({required String userId}) async {
    final snapshot =
        await _firestore.collection('reviews').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }

  // ────────────── GET MOVIE BY ID ──────────────
  Future<Map<String, dynamic>?> getMovieById(String movieId) async {
    final doc = await _firestore.collection('movies').doc(movieId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  // ────────────── SEARCH MOVIE ──────────────
  Future<List<Map<String, dynamic>>> searchMovie({required String title}) async {
    final snapshot = await _firestore
        .collection('movies')
        .where('title', isGreaterThanOrEqualTo: title)
        .where('title', isLessThanOrEqualTo: title + '\uf8ff')
        .get();
    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }
}
