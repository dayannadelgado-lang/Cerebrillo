// ESTA PAGINA SI LA VAN A MODIFICAR TANTO LOGICA Y DISEÑO (recursos de diseño en assets)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//MODIFICARAN EL DISEÑO COMPLETAMENTE PARA QUE HAYA SIMILITUD QUE EN RESTO, en diseño es muy equis este codigo solo es como la base okey
//TANTO HARDY Y JOSUE EN LOS ARCHIVOS EN ASSETS/IMAGES HAY IMAGENES no les cambien el nombre unicamente si van a usar una imagen de fondo hay dos opciones
// que usen el mismo nombre o dupliquen la imagen y le modifiquen el nombre de acuerdo a la pagina pero a la imagen original no le cambien nombre les marcara error



///  Primero defino el modelo Habit
/// Este modelo es la "estructura" que representa cada hábito en la app
/// Aquí tambien guardo: id, título, descripción y si ya se completó o no.
class Habit {
  final String id;
  final String title;
  final String description;
  bool isCompleted;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

/// Esta es la página principal donde se va a mostrar y manejar los hábitos
/// Es un StatefulWidget porque se necesita actualizar el estado cuando agrego o completo hábitos
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  /// Aquí guardo todos los hábitos en una lista que se ira mostrando en pantalla.
  final List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    /// Apenas cargo la página, llamo a esta función
    /// para traer todos los hábitos guardados en Firestore.
    _loadHabitsFromFirestore();
  }

  /// Esta función se conecta con Firestore.
  /// aca se verifica solo PERO JOSUE O HARDY IGUAL VERIFIQUEN QUE SI SE GUARDEN EN FIRESTORE
  /// Lo que hago aquí es:
  /// - Verificar qué usuario está logueado en FirebaseAuth
  /// - Ir a la colección "usuarios/{uid}/habits"
  /// - Obtener todos los hábitos guardados y transformarlos en objetos Habit
  Future<void> _loadHabitsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('habits')
        .get();

    setState(() {
      _habits.clear();
      _habits.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return Habit(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          isCompleted: data['isCompleted'] ?? false,
        );
      }));
    });
  }

  /// Con esta función alterno el estado de un hábito
  /// Si estaba incompleto lo marco como completo y viceversa
  /// También actualizo el valor en Firestore para que quede guardado igual verifiquen que si se haya realizado la actualizacion
  void _toggleHabit(String id) async {
    setState(() {
      final habit = _habits.firstWhere((h) => h.id == id);
      habit.isCompleted = !habit.isCompleted;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final habit = _habits.firstWhere((h) => h.id == id);
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('habits')
          .doc(habit.id)
          .set({
        'title': habit.title,
        'description': habit.description,
        'isCompleted': habit.isCompleted,
      });
    }
  }

  /// Aquí agrego un nuevo hábito
  /// - Esto creo un documento nuevo en Firestore dentro de "usuarios/{uid}/habits"
  /// y esto se guarda en la lista local para que se muestre en pantalla
  void _addHabit(String title, String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('habits')
        .doc();

    final newHabit = Habit(
      id: docRef.id,
      title: title,
      description: description,
    );

    setState(() {
      _habits.add(newHabit);
    });

    await docRef.set({
      'title': title,
      'description': description,
      'isCompleted': newHabit.isCompleted,
    });
  }

  /// Esta función abre un cuadro de diálogo para que el usuario
  /// escriba el título y la descripción de un hábito nuevo (este modifiquen el diseño,que sea mas ameno)
  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nuevo Hábito"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descripción"),
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
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                _addHabit(titleController.text, descriptionController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  /// Aquí construyo la interfaz
  /// - Si no hay hábitos, muestro un mensaje invitando a agregar uno
  /// - Si hay hábitos, los muestro en una lista con un checkbox para marcarlos 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hábitos"),
      ),
      body: _habits.isEmpty
          ? const Center(
              child: Text("No tienes hábitos todavía. Agrega uno nuevo."),
            )
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (ctx, index) {
                final habit = _habits[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    /// Aquí pongo un checkbox para marcar si ya completé el hábito
                    leading: Checkbox(
                      value: habit.isCompleted,
                      onChanged: (_) => _toggleHabit(habit.id),
                    ),
                    /// Aquí muestro el título del hábito
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        /// Si ya está completado, le pongo tachado al texto
                        decoration: habit.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    /// Y abajo muestro la descripción
                    subtitle: Text(habit.description),
                  ),
                );
              },
            ),
      /// Este botón flotante sirve para abrir el diálogo y agregar un nuevo hábito
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
