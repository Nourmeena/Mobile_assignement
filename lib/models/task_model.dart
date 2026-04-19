class TaskModel {
  int? id;
  String title;
  String? description;
  String dueDate;
  String priority;
  bool isCompleted;
  int? userId;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'userId': userId,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      userId: map['userId'],
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    bool? isCompleted,
    int? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}
