import 'package:cloud_firestore/cloud_firestore.dart';

class ListUserReviewsVariablesBuilder {
  final String userId;

  ListUserReviewsVariablesBuilder({required this.userId});

  Future<ListUserReviewsData> execute() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return ListUserReviewsData(user: null);
    }

    final userData = userDoc.data()!;
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('reviews')
        .get();

    List<ListUserReviewsUserReviews> reviews = [];

    for (var doc in reviewsSnapshot.docs) {
      final data = doc.data();
      // Obtener datos de la película referenciada
      final movieDoc = await FirebaseFirestore.instance.collection('movies').doc(data['movieId']).get();
      final movieData = movieDoc.data();
      if (movieData == null) continue;

      reviews.add(
        ListUserReviewsUserReviews(
          rating: data['rating'],
          reviewDate: (data['reviewDate'] as Timestamp).toDate(),
          reviewText: data['reviewText'],
          movie: ListUserReviewsUserReviewsMovie(
            id: movieDoc.id,
            title: movieData['title'] ?? '',
          ),
        ),
      );
    }

    return ListUserReviewsData(
      user: ListUserReviewsUser(
        id: userDoc.id,
        username: userData['username'] ?? '',
        reviews: reviews,
      ),
    );
  }
}

// ────────────── MODEL CLASSES ──────────────
class ListUserReviewsUser {
  String id;
  String username;
  List<ListUserReviewsUserReviews> reviews;

  ListUserReviewsUser({
    required this.id,
    required this.username,
    required this.reviews,
  });
}

class ListUserReviewsUserReviews {
  int? rating;
  DateTime reviewDate;
  String? reviewText;
  ListUserReviewsUserReviewsMovie movie;

  ListUserReviewsUserReviews({
    this.rating,
    required this.reviewDate,
    this.reviewText,
    required this.movie,
  });
}

class ListUserReviewsUserReviewsMovie {
  String id;
  String title;

  ListUserReviewsUserReviewsMovie({
    required this.id,
    required this.title,
  });
}

class ListUserReviewsData {
  ListUserReviewsUser? user;

  ListUserReviewsData({this.user});
}
