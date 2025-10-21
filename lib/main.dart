import 'package:flutter/material.dart';

// --- 1. Data Model ---
// A simple class to represent a Task
class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});
}

void main() {
  runApp(const TaskManagerApp());
}

// --- 2. Main App Widget (Stateless) ---
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}

// --- 3. Main Screen (StatefulWidget) ---
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // R - Read: The core list holding our task data (Instance variable)
  final List<Task> _tasks = [
    Task(name: "Complete Flutter Assignment"),
    Task(name: "Buy Groceries", isCompleted: true),
    Task(name: "Go for a run"),
  ];

  // Controller for the text input field
  final TextEditingController _taskController = TextEditingController();

  // C - Create: Adds a new task to the list
  void _addTask() {
    final taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      // Use setState to trigger a UI rebuild with the new task
      setState(() {
        _tasks.add(Task(name: taskName));
        _taskController.clear(); // Clear the input field after adding
      });
    }
  }

  // U - Update: Toggles the completion status of a task
  void _toggleTaskCompletion(Task task) {
    // Use setState to trigger a UI rebuild with the updated task status
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  // D - Delete: Removes a task from the list
  void _deleteTask(Task task) {
    // Use setState to trigger a UI rebuild after removing the task
    setState(() {
      _tasks.remove(task);
    });
  }

  // Always dispose of controllers to free up resources
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to a very mild blue
      backgroundColor: Colors.blue.shade50, 
      
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // --- Task Input Field and Add Button (Create) ---
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter a new task',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      prefixIcon: const Icon(Icons.add_task),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    onSubmitted: (_) => _addTask(), // Allows adding with 'Enter' key
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addTask,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    minimumSize: const Size(60, 50)
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const Divider(height: 30),

            // --- Task List View (Read) ---
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet! Add one above. 🎉',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            // Checkbox for completion (Update)
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? newValue) {
                                _toggleTaskCompletion(task);
                              },
                              activeColor: Colors.green,
                            ),
                            // Task Name (Read)
                            title: Text(
                              task.name,
                              style: TextStyle(
                                // Strikethrough for completed tasks
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted ? Colors.grey : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            // Delete Button (Delete)
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteTask(task),
                              tooltip: 'Delete Task',
                            ),
                            onTap: () => _toggleTaskCompletion(task), // Tap the tile to toggle
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}