//JOSUE Y HARDY ESTA PAGINA TAMBIEN DEBERAN EDITARLA ES DE PENDIENTES Y DEBERA NOTICAR AL USUARIO 
// EL DISEÑO SOLO ERA PARA LLENAR LA PAGINA LO DEBERAN MODIFICAR PERO ES UNA BASE


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class PendientesPage extends StatefulWidget {
  const PendientesPage({super.key});

  @override
  PendientesPageState createState() => PendientesPageState();
}

class PendientesPageState extends State<PendientesPage> {
  List<Map<String, dynamic>> pendientes = [];

  @override
  void initState() {
    super.initState();
    _loadPendientesFromFirestore();
  }

  /// Cargar pendientes desde Firestore
  Future<void> _loadPendientesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .get();

    setState(() {
      pendientes = snapshot.docs
          .map((doc) => {'id': doc.id, 'text': doc.data()['text'] ?? ''})
          .toList();
    });
  }

  ///  Agregar pendiente a Firestore
  Future<void> addPendiente(String pendiente) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .add({'text': pendiente});

    setState(() {
      pendientes.add({'id': docRef.id, 'text': pendiente});
    });
  }

  ///  Eliminar pendiente de Firestore
  Future<void> removePendiente(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .doc(id)
        .delete();

    setState(() {
      pendientes.removeWhere((element) => element['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pendientes'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController();
                    return AlertDialog(
                      title: const Text("Agregar pendiente"),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              addPendiente(controller.text);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Agregar"),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary),
              child: const Text("Agregar pendiente"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pendientes.length,
                itemBuilder: (context, index) {
                  final pendiente = pendientes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(pendiente['text']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removePendiente(pendiente['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
