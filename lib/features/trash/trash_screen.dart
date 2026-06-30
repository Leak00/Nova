import 'package:flutter/material.dart';
import '../../data/database/history_db.dart';
import '../../data/database/task_db.dart';
import '../../data/models/task_model.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final TaskDB db = TaskDB();
  final HistoryDB historyDB = HistoryDB();
  List<TaskModel> deletedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedTasks();
  }

  Future<void> _loadDeletedTasks() async {
    final tasks = await db.getDeletedTasks();
    if (!mounted) return;
    setState(() {
      deletedTasks = tasks;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trash', style: TextStyle(color: Colors.white)), elevation: 0, backgroundColor: Colors.blueAccent,),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Recover deleted tasks or remove them forever.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildTrashList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrashList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (deletedTasks.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6CFF).withAlpha(31),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 50,
                  color: Color(0xFF5B6CFF),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Trash is empty',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deleted tasks will appear here so you can restore them later.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: deletedTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = deletedTasks[index];
        return _buildTrashItem(task);
      },
    );
  }

  Widget _buildTrashItem(TaskModel task) {
    final deletedDate = task.deletedAt != null
        ? _formatDate(task.deletedAt!)
        : 'Unknown date';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.grey[50],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(31),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B6CFF).withAlpha(31),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF5B6CFF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              deletedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _restoreTask(task.id),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restore'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _permanentlyDeleteTask(task.id),
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restoreTask(String id) async {
    await db.restoreTask(id);
    final restoredTask = deletedTasks.firstWhere(
      (task) => task.id == id,
      orElse: () => TaskModel(id: '', title: '', category: ''),
    );

    if (restoredTask.id.isNotEmpty) {
      historyDB.addEvent(
        HistoryEvent(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          taskId: restoredTask.id,
          title: restoredTask.title,
          subtitle: 'Restored to ${restoredTask.category}',
          actionType: 'restored',
          occurredAt: DateTime.now(),
        ),
      );
    }

    await _loadDeletedTasks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task restored successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _permanentlyDeleteTask(String id) async {
    final deletedTask = deletedTasks.firstWhere(
      (task) => task.id == id,
      orElse: () => TaskModel(id: '', title: '', category: ''),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: const Text(
          'This action cannot be undone. The task will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await db.deleteTask(id);
    if (deletedTask.id.isNotEmpty) {
      historyDB.addEvent(
        HistoryEvent(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          taskId: deletedTask.id,
          title: deletedTask.title,
          subtitle: 'Permanently deleted',
          actionType: 'permanently_deleted',
          occurredAt: DateTime.now(),
        ),
      );
    }

    await _loadDeletedTasks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted permanently'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
