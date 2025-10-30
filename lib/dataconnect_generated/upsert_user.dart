// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class UpsertUserVariablesBuilder {
  String username;

  UpsertUserVariablesBuilder({required this.username});

  /// Inserta o actualiza un usuario en Firestore
  Future<UpsertUserData> execute() async {
    final collection = FirebaseFirestore.instance.collection('users');

    // Buscamos si existe el usuario por username
    final query = await collection.where('username', isEqualTo: username).get();

    String userId;
    if (query.docs.isNotEmpty) {
      // Usuario ya existe, usamos su id
      userId = query.docs.first.id;
      await collection.doc(userId).update({'username': username});
    } else {
      // Usuario nuevo
      final docRef = await collection.add({'username': username});
      userId = docRef.id;
    }

    return UpsertUserData(
      user_upsert: UpsertUserUserUpsert(id: userId),
    );
  }
}

// ────────────── MODEL CLASSES ──────────────
class UpsertUserUserUpsert {
  String id;

  UpsertUserUserUpsert({required this.id});

  factory UpsertUserUserUpsert.fromJson(Map<String, dynamic> json) {
    return UpsertUserUserUpsert(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class UpsertUserData {
  UpsertUserUserUpsert user_upsert;

  UpsertUserData({required this.user_upsert});

  factory UpsertUserData.fromJson(Map<String, dynamic> json) {
    return UpsertUserData(
        user_upsert: UpsertUserUserUpsert.fromJson(json['user_upsert']));
  }

  Map<String, dynamic> toJson() {
    return {'user_upsert': user_upsert.toJson()};
  }
}
