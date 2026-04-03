import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

const _uuid = Uuid();

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier() : super([]);

  void addTask(String title, TaskPriority priority) {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      priority: priority,
    );
    state = [...state, task];
  }

  void toggleTask(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>(
  (ref) => TasksNotifier(),
);
