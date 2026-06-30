import 'package:flutter/material.dart';
import '../../data/database/history_db.dart';
import '../../data/database/task_db.dart';
import '../../data/models/task_model.dart';
import 'task_screen_sheet.dart';

class TaskScreen extends StatefulWidget {
  final String category;

  const TaskScreen({super.key, required this.category});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskDB db = TaskDB();
  final HistoryDB historyDB = HistoryDB();

  List<TaskModel> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await db.getTasks(category: widget.category);
    if (!mounted) return;
    setState(() {
      tasks = fetchedTasks;
      isLoading = false;
    });
  }

  Future<void> _addTask(String title, String category) async {
    final task = await db.addTask(
      TaskModel(id: '', title: title, category: category),
    );

    historyDB.addEvent(
      HistoryEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        taskId: task.id,
        title: task.title,
        subtitle: 'Added to $category',
        actionType: 'added',
        occurredAt: DateTime.now(),
      ),
    );

    await _loadTasks();
  }

  Future<void> _editTask(String taskId, String title, String category) async {
    final task = tasks.firstWhere((element) => element.id == taskId);
    final oldTitle = task.title;
    final oldCategory = task.category;
    task.title = title;
    task.category = category;

    final updatedTask = await db.updateTask(task);

    historyDB.addEvent(
      HistoryEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        taskId: updatedTask.id,
        title: updatedTask.title,
        subtitle: oldTitle == title
            ? 'Moved from $oldCategory to $category'
            : 'Updated task details',
        actionType: 'edited',
        occurredAt: DateTime.now(),
      ),
    );

    await _loadTasks();
  }

  Future<void> _toggleTask(TaskModel task, bool? value) async {
    task.isDone = value ?? false;
    final updatedTask = await db.updateTask(task);

    historyDB.addEvent(
      HistoryEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        taskId: updatedTask.id,
        title: updatedTask.title,
        subtitle: updatedTask.isDone ? 'Marked complete' : 'Marked incomplete',
        actionType: updatedTask.isDone ? 'completed' : 'reopened',
        occurredAt: DateTime.now(),
      ),
    );

    await _loadTasks();
  }

  Future<void> _deleteTask(TaskModel task) async {
    await db.softDeleteTask(task.id);
    historyDB.addEvent(
      HistoryEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        taskId: task.id,
        title: task.title,
        subtitle: 'Deleted from ${task.category}',
        actionType: 'deleted',
        occurredAt: DateTime.now(),
      ),
    );
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(widget.category, style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TASKS',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks found in ${widget.category}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: task.isDone,
                                onChanged: (value) => _toggleTask(task, value),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.purple),
                                onPressed: () {
                                  showTaskBottomSheet(
                                    context,
                                    isEdit: true,
                                    initialTitle: task.title,
                                    initialCategory: task.category,
                                    onSave: (title, category) {
                                      _editTask(task.id, title, category);
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteTask(task);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTaskBottomSheet(
            context,
            initialCategory: widget.category,
            onSave: (title, category) {
              _addTask(title, category);
            },
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
