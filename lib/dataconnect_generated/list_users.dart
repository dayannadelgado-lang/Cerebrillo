import 'package:cloud_firestore/cloud_firestore.dart';

class ListUsersVariablesBuilder {
  ListUsersVariablesBuilder();

  Future<ListUsersData> execute() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    List<ListUsersUsers> users = snapshot.docs.map((doc) {
      final data = doc.data();
      return ListUsersUsers(
        id: doc.id,
        username: data['username'] ?? '',
      );
    }).toList();

    return ListUsersData(users: users);
  }
}

// ────────────── MODEL CLASSES ──────────────
class ListUsersUsers {
  String id;
  String username;

  ListUsersUsers({
    required this.id,
    required this.username,
  });

  factory ListUsersUsers.fromJson(Map<String, dynamic> json) {
    return ListUsersUsers(
      id: json['id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}

class ListUsersData {
  List<ListUsersUsers> users;

  ListUsersData({required this.users});

  factory ListUsersData.fromJson(Map<String, dynamic> json) {
    return ListUsersData(
      users: (json['users'] as List<dynamic>)
          .map((e) => ListUsersUsers.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((e) => e.toJson()).toList(),
    };
  }
}
