import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../../../core/database/database_helper.dart';

const _uuid = Uuid();

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final rows = await DatabaseHelper.instance.getTasks();
    state = rows.map(TaskModel.fromMap).toList();
  }

  Future<void> addTask(String title, TaskPriority priority) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      priority: priority,
    );
    await DatabaseHelper.instance.insertTask(task.toMap());
    state = [...state, task];
  }

  Future<void> toggleTask(String id) async {
    state = state.map((task) {
      if (task.id == id) return task.copyWith(isCompleted: !task.isCompleted);
      return task;
    }).toList();
    final updated = state.firstWhere((t) => t.id == id);
    await DatabaseHelper.instance.updateTask(updated.toMap());
  }

  Future<void> deleteTask(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    state = state.where((task) => task.id != id).toList();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>(
  (ref) => TasksNotifier(),
);
