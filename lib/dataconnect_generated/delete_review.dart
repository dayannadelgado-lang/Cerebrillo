import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteReviewVariables {
  String movieId;
  String userId; // Añadido para identificar la reseña

  DeleteReviewVariables({
    required this.movieId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'userId': userId,
    };
  }
}

class DeleteReviewData {
  String? deletedReviewId;

  DeleteReviewData({this.deletedReviewId});
}

class DeleteReview {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Borra la reseña de un usuario en una película específica
  Future<DeleteReviewData> execute(DeleteReviewVariables vars) async {
    try {
      // Referencia a la colección de reviews dentro de cada película
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('movieId', isEqualTo: vars.movieId)
          .where('userId', isEqualTo: vars.userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return DeleteReviewData(deletedReviewId: null);
      }

      // Borramos todos los documentos encontrados (generalmente será uno)
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      return DeleteReviewData(deletedReviewId: querySnapshot.docs.first.id);
    } catch (e) {
      rethrow;
    }
  }
}
