//HARDY ESTA ES LA PAGINA DE TAREAS ESTA DE MANERA SIMPLE ASI QUE DEBERAS AÑADIR MAS COSAS Y MODIFICA EL CODIGO EN DISEÑO 


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_model.dart';
import '../utils/colors.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final CollectionReference remindersCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> _addNewTask() async {
    final newTask = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nueva tarea',
      description: 'Descripción de la tarea',
      reminderDate: DateTime.now(),
    );
    await remindersCollection.doc(newTask.id).set(newTask.toMap());
  }

  Future<void> _toggleTaskCompletion(Reminder task) async {
    await remindersCollection
        .doc(task.id)
        .update({'isCompleted': !task.isCompleted});
  }

  Future<void> _deleteTask(String id) async {
    await remindersCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: remindersCollection.orderBy('reminderDate').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs
              .map((doc) => Reminder.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No hay tareas aún',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return GestureDetector(
                onLongPress: () => _deleteTask(task.id),
                child: Card(
                  color:
                      task.isCompleted ? Colors.green.shade100 : AppColors.background,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(task.description),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => _toggleTaskCompletion(task),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
