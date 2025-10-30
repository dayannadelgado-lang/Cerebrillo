import 'package:cloud_firestore/cloud_firestore.dart';

class GetMovieByIdVariablesBuilder {
  String id;

  GetMovieByIdVariablesBuilder({required this.id});

  Future<GetMovieByIdData?> execute() async {
    final doc = await FirebaseFirestore.instance.collection('movies').doc(id).get();

    if (!doc.exists) return null;

    // Obtener reviews relacionadas
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('movieId', isEqualTo: id)
        .get();

    List<GetMovieByIdMovieReviews> reviews = reviewsSnapshot.docs.map((reviewDoc) {
      final data = reviewDoc.data();
      return GetMovieByIdMovieReviews(
        reviewText: data['reviewText'] as String?,
        reviewDate: (data['reviewDate'] as Timestamp).toDate(),
        rating: data['rating'] as int?,
        user: GetMovieByIdMovieReviewsUser(
          id: data['userId'] ?? '',
          username: data['username'] ?? '',
        ),
      );
    }).toList();

    final movieData = doc.data()!;
    final movie = GetMovieByIdMovie(
      id: doc.id,
      title: movieData['title'] ?? '',
      imageUrl: movieData['imageUrl'] ?? '',
      genre: movieData['genre'],
      metadata: GetMovieByIdMovieMetadata(
        rating: (movieData['rating'] as num?)?.toDouble(),
        releaseYear: movieData['releaseYear'] as int?,
        description: movieData['description'] as String?,
      ),
      reviews: reviews,
    );

    return GetMovieByIdData(movie: movie);
  }
}

// ────────────── MODEL CLASSES ──────────────
class GetMovieByIdData {
  GetMovieByIdMovie? movie;
  GetMovieByIdData({this.movie});
}

class GetMovieByIdMovie {
  String id;
  String title;
  String imageUrl;
  String? genre;
  GetMovieByIdMovieMetadata? metadata;
  List<GetMovieByIdMovieReviews> reviews;

  GetMovieByIdMovie({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.genre,
    this.metadata,
    required this.reviews,
  });
}

class GetMovieByIdMovieMetadata {
  double? rating;
  int? releaseYear;
  String? description;

  GetMovieByIdMovieMetadata({this.rating, this.releaseYear, this.description});
}

class GetMovieByIdMovieReviews {
  String? reviewText;
  DateTime reviewDate;
  int? rating;
  GetMovieByIdMovieReviewsUser user;

  GetMovieByIdMovieReviews({
    this.reviewText,
    required this.reviewDate,
    this.rating,
    required this.user,
  });
}

class GetMovieByIdMovieReviewsUser {
  String id;
  String username;

  GetMovieByIdMovieReviewsUser({required this.id, required this.username});
}
