class TaskModel {
  String id;
  String title;
  String category;
  bool isDone;
  bool isDeleted;
  DateTime? deletedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.category = 'General',
    this.isDone = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isDone': isDone,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map data) {
    final deletedAtValue = data['deletedAt'] ?? data['deleted_at'];
    final rawId = data['id'];
    final id = rawId != null ? rawId.toString() : '';

    return TaskModel(
      id: id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      isDone: data['isDone'] ?? data['is_done'] ?? false,
      isDeleted: data['isDeleted'] ?? data['is_deleted'] ?? false,
      deletedAt: deletedAtValue != null
          ? DateTime.parse(deletedAtValue as String)
          : null,
    );
  }
}
