import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

// --- Data Model ---

// A simple class to represent a Task
class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});
}

// --- Main App Widget ---

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
      ),
      home: const TaskListScreen(),
    );
  }
}

// --- Main Screen (StatefulWidget) ---

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // R - Read: The core list holding our task data
  final List<Task> _tasks = [
    Task(name: "Complete Flutter Assignment"),
    Task(name: "Buy Groceries", isCompleted: true),
    Task(name: "Go for a run"),
  ];

  // Controller for the text input field
  final TextEditingController _taskController = TextEditingController();

  // C - Create: Adds a new task to the list
  void _addTask() {
    // Check if the input field is not empty
    if (_taskController.text.isNotEmpty) {
      // Use setState to rebuild the UI with the new task
      setState(() {
        _tasks.add(Task(name: _taskController.text));
        _taskController.clear(); // Clear the input field after adding
      });
    }
  }

  // U - Update: Toggles the completion status of a task
  void _toggleTaskCompletion(Task task) {
    // Use setState to rebuild the UI with the updated task status
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  // D - Delete: Removes a task from the list
  void _deleteTask(Task task) {
    // Use setState to rebuild the UI after removing the task
    setState(() {
      _tasks.remove(task);
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager 📋'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // --- Task Input Field and Add Button ---
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(), // Allows adding with 'Enter' key
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const Divider(height: 30),

            // --- Task List View ---
            // The Expanded widget ensures the ListView takes the remaining space
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  // Each task is represented by a ListTile
                  return ListTile(
                    // Checkbox for completion (Update)
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? newValue) {
                        _toggleTaskCompletion(task);
                      },
                    ),
                    // Task Name (Read)
                    title: Text(
                      task.name,
                      style: TextStyle(
                        // Strikethrough for completed tasks
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    // Delete Button (Delete)
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(task),
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