// lib/services/firebase_service.dart
// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ------------------- AUTENTICACIÓN -------------------

  // Registrar usuario con email y contraseña
  Future<UserCredential> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Crear documento del usuario en Firestore
    await createUser(
      uid: credential.user!.uid,
      name: name,
      email: email,
    );

    return credential;
  }

  // Login con email y contraseña
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // ------------------- USUARIO -------------------

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'perfil': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['perfil'] ?? '';
  }

  // ------------------- DIARIO -------------------

  Future<void> addDiarioEntry({
    required String uid,
    required String title,
    required String content,
  }) async {
    await _db.collection('users').doc(uid).collection('diario').add({
      'title': title,
      'content': content,
      'date': FieldValue.serverTimestamp(),
      'completed': false,
    });
  }

  Future<QuerySnapshot> getDiarioEntries(String uid) async {
    return await _db.collection('users').doc(uid).collection('diario').get();
  }

  // ------------------- RECORDATORIOS -------------------

  Future<void> addReminder({
    required String uid,
    required String title,
    required String description,
    required DateTime dateTime,
  }) async {
    await _db.collection('users').doc(uid).collection('recordatorios').add({
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'notified': false,
    });
  }

  Future<QuerySnapshot> getReminders(String uid) async {
    return await _db.collection('users').doc(uid).collection('recordatorios').get();
  }

  // ------------------- LOGROS -------------------

  Future<void> addLogro({
    required String uid,
    required String title,
    required String description,
  }) async {
    await _db.collection('users').doc(uid).collection('logros').add({
      'title': title,
      'description': description,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getLogros(String uid) async {
    return await _db.collection('users').doc(uid).collection('logros').get();
  }

  // ------------------- TIPS -------------------

  Future<void> addTip({
    required String uid,
    required String title,
    required String description,
    String category = 'general',
  }) async {
    await _db.collection('users').doc(uid).collection('tips').add({
      'title': title,
      'description': description,
      'category': category,
      'completed': false,
    });
  }

  Future<QuerySnapshot> getTips(String uid) async {
    return await _db.collection('users').doc(uid).collection('tips').get();
  }

  // ------------------- NOTIFICACIONES -------------------

  Future<void> addNotification({
    required String uid,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _db.collection('users').doc(uid).collection('notificaciones').add({
      'title': title,
      'body': body,
      'dateTime': dateTime,
      'seen': false,
    });
  }

  Future<QuerySnapshot> getNotifications(String uid) async {
    return await _db.collection('users').doc(uid).collection('notificaciones').get();
  }
}
