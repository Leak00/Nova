import 'package:flutter/material.dart';
import '../../data/database/task_db.dart';
import '../../data/models/task_model.dart';
import 'task_screen.dart';
import 'task_screen_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskDB db = TaskDB();
  final List<Map<String, dynamic>> categories = [
    {'name': 'Work',
     'icon': Icons.folder_open_outlined,
     'color': Colors.blue},
    {
      'name': 'Personal',
      'icon': Icons.folder_open_outlined,
      'color': Colors.purple,
    },
    {
      'name': 'Shopping',
      'icon': Icons.folder_open_outlined,
      'color': Colors.teal,
    },
    {'name': 'General',
      'icon': Icons.folder_open_outlined,
      'color': Colors.orange,

    },
  ];

  List<TaskModel> allTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await db.getTasks();
    if (!mounted) return;
    setState(() {
      allTasks = tasks;
      isLoading = false;
    });
  }

  int countFor(String category) {
    return allTasks.where((task) => task.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('NOVA Pro', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = categories[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => TaskScreen(category: item['name']),
                          ),
                        )
                        .then((_) => _loadTasks());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${countFor(item['name'] as String)} tasks',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final oldName = item['name'] as String;
                            showCategoryBottomSheet(
                              context,
                              isEdit: true,
                              initialName: oldName,
                              onSave: (updatedName) async {
                                if (updatedName != oldName) {
                                  await db.updateTaskCategory(
                                    oldName,
                                    updatedName,
                                  );
                                  await _loadTasks();
                                }
                                if (!mounted) return;
                                setState(() {
                                  categories[index]['name'] = updatedName;
                                });
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.purple,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              categories.removeAt(index);
                            });
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCategoryBottomSheet(
            context,
            onSave: (categoryName) {
              setState(() {
                categories.add({
                  'name': categoryName,
                  'icon': Icons.folder_open_outlined,
                  'color': Colors.indigo,
                });
              });
            },
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
