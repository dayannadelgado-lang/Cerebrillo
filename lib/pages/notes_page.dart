//HARDY Y JOSUE ESTA PAGINA ES PARA TOMAR NOTAS EN CLASE,PERO PUEDEN MODIFICARLA PARA TAREAS ES UN DISEÑO SUPERFICIAL
// ASI QUE DEBERAN MODIFICARLO QUITANTO EL APPBAR CAMBIANDO EL FONDO ETC

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../utils/colors.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  List<Note> notes = [];
  late AnimationController _noteAnimationController;

  @override
  void initState() {
    super.initState();
    _noteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadNotesFromFirestore(); // 🔹 cargar notas al iniciar
  }

  @override
  void dispose() {
    _noteAnimationController.dispose();
    super.dispose();
  }

  /// 🔹 Cargar notas desde Firestore
  Future<void> _loadNotesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        notes = snapshot.docs.map((doc) {
          final data = doc.data();
          return Note(
            id: doc.id,
            title: data['title'] ?? '',
            content: data['content'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("❌ Error cargando notas de Firestore: $e");
    }
  }

  /// 🔹 Agregar nota y guardar en Firestore
  Future<void> addNote(String title, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('notes')
        .doc();

    final newNote = Note(
      id: docRef.id,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      notes.insert(0, newNote); // insertamos arriba para que sea visible
    });

    _noteAnimationController.forward(from: 0); // animación al añadir

    try {
      await docRef.set({
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Error guardando nota en Firestore: $e");
    }
  }

  void _showAddNoteDialog() {
    String title = '';
    String content = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nueva Nota"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Título"),
              onChanged: (val) => title = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Contenido"),
              onChanged: (val) => content = val,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty) {
                addNote(title, content);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notas"),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ScaleTransition(
            scale: _noteAnimationController.drive(
              Tween<double>(begin: 0.8, end: 1.0).chain(
                CurveTween(curve: Curves.easeOut),
              ),
            ),
            child: Card(
              color: AppColors.backgroundCard,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                title: Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(note.content),
                trailing: Text(
                  "${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
