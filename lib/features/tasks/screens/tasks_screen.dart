import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/tasks_provider.dart';
import '../../../core/theme/app_theme.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nueva tarea',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '¿Qué necesitas hacer?',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prioridad',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  selected: {selectedPriority},
                  onSelectionChanged: (value) => setModalState(() => selectedPriority = value.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppTheme.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: TaskPriority.high,
                      label: Text('Alta'),
                      icon: Icon(Icons.arrow_upward, size: 16),
                    ),
                    ButtonSegment(
                      value: TaskPriority.medium,
                      label: Text('Media'),
                      icon: Icon(Icons.remove, size: 16),
                    ),
                    ButtonSegment(
                      value: TaskPriority.low,
                      label: Text('Baja'),
                      icon: Icon(Icons.arrow_downward, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isNotEmpty) {
                        ref.read(tasksProvider.notifier).addTask(title, selectedPriority);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Agregar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFEF5350);
      case TaskPriority.medium:
        return const Color(0xFFFFA726);
      case TaskPriority.low:
        return const Color(0xFF66BB6A);
    }
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline, size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay tareas para hoy 🎉',
                    style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca el botón + para agregar una',
                    style: TextStyle(fontSize: 13, color: Color(0xFFB0BEC5)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => ref.read(tasksProvider.notifier).toggleTask(task.id),
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: task.isCompleted ? const Color(0xFFB0BEC5) : const Color(0xFF2D2D2D),
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    decorationColor: const Color(0xFFB0BEC5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _priorityColor(task.priority).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _priorityLabel(task.priority),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _priorityColor(task.priority),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref.read(tasksProvider.notifier).deleteTask(task.id),
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
                            tooltip: 'Eliminar tarea',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        tooltip: 'Agregar tarea',
        child: const Icon(Icons.add),
      ),
    );
  }
}
