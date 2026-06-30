import '../models/task_model.dart';
import '../../services/api_service.dart';

class TaskDB {
  Future<List<TaskModel>> getTasks({String? category}) async {
    return ApiService.getTasks(category: category, deleted: false);
  }

  Future<List<TaskModel>> getDeletedTasks() async {
    return ApiService.getTasks(deleted: true);
  }

  Future<TaskModel> addTask(TaskModel task) async {
    return ApiService.createTask(task.title, task.category);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    return ApiService.updateTask(task);
  }

  Future<void> softDeleteTask(String id) async {
    await ApiService.deleteTask(id);
  }

  Future<void> restoreTask(String id) async {
    await ApiService.restoreTask(id);
  }

  Future<void> updateTaskCategory(
    String fromCategory,
    String toCategory,
  ) async {
    final tasks = await getTasks(category: fromCategory);
    await Future.wait(
      tasks.map((task) {
        task.category = toCategory;
        return updateTask(task);
      }),
    );
  }

  Future<void> deleteTask(String id) async {
    await ApiService.forceDeleteTask(id);
  }

  Future<void> toggleTask(TaskModel task) async {
    task.isDone = !task.isDone;
    await updateTask(task);
  }
}
