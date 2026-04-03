enum TaskPriority { high, medium, low }

class TaskModel {
  final String id;
  final String title;
  final TaskPriority priority;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.priority,
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
