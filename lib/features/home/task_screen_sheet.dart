import 'package:flutter/material.dart';

void showTaskBottomSheet(
  BuildContext context, {
  bool isEdit = false,
  String? initialTitle,
  String? initialCategory,
  required void Function(String title, String category) onSave,
}) {
  final titleController = TextEditingController(text: initialTitle ?? '');
  final categories = ['Work', 'Personal', 'Shopping', 'General'];
  if (initialCategory != null && !categories.contains(initialCategory)) {
    categories.insert(0, initialCategory);
  }
  String selectedCategory = initialCategory ?? categories.first;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isEdit ? 'Edit Task' : 'Add New Task',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Task Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;
                      onSave(title, selectedCategory);
                      Navigator.pop(context);
                    },
                    child: Text(
                      isEdit ? 'Save Changes' : '+ Add Task',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showCategoryBottomSheet(
  BuildContext context, {
  bool isEdit = false,
  String? initialName,
  required void Function(String categoryName) onSave,
}) {
  final categoryController = TextEditingController(text: initialName ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEdit ? 'Edit Category' : 'Add New Category',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, color: Colors.blueAccent,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                hintText: 'Category Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () {
                  final name = categoryController.text.trim();
                  if (name.isEmpty) return;
                  onSave(name);
                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save Category' : '+ Add Category', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    },
  );
}
