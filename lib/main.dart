import 'package:flutter/material.dart';

// --- 1. Priority Enum and Data Model ---

enum TaskPriority { Low, Medium, High }

class Task {
  String name;
  bool isCompleted;
  TaskPriority priority;

  Task({
    required this.name,
    this.isCompleted = false,
    this.priority = TaskPriority.Medium,
  });
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
  final List<Task> _tasks = [
    Task(name: "Complete Flutter Assignment", priority: TaskPriority.High),
    Task(name: "Buy Groceries", isCompleted: true, priority: TaskPriority.Medium),
    Task(name: "Go for a run", priority: TaskPriority.Low),
  ];

  final TextEditingController _taskController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.Medium; 

  void _addTask() {
    final taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          name: taskName,
          priority: _selectedPriority,
        ));
        _taskController.clear();
        _selectedPriority = TaskPriority.Medium;
      });
    }
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.High:
        return Colors.red.shade600;
      case TaskPriority.Medium:
        return Colors.amber.shade700;
      case TaskPriority.Low:
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      
      appBar: AppBar(
        title: const Text('Task Manager 📋'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // --- INPUT SECTION: Task Name, Priority Dropdown, and Add Button ---
            
            // 1. Task Name Input Field (Full Width)
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                hintText: 'Task name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              onSubmitted: (_) => _addTask(),
            ),
            const SizedBox(height: 12),

            // 2. Priority Dropdown and Add Button (In a Row)
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    value: _selectedPriority,
                    decoration: InputDecoration(
                       labelText: 'Priority',
                       border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                       contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                    onChanged: (TaskPriority? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPriority = newValue;
                        });
                      }
                    },
                    items: TaskPriority.values
                        .map<DropdownMenuItem<TaskPriority>>((TaskPriority value) {
                      return DropdownMenuItem<TaskPriority>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Add Button
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

            // --- Task List View ---
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
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? newValue) => _toggleTaskCompletion(task),
                              activeColor: Colors.green,
                            ),
                            title: Text(
                              task.name,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted ? Colors.grey : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Priority: ${task.priority.name}",
                              style: TextStyle(
                                color: _getPriorityColor(task.priority),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteTask(task),
                              tooltip: 'Delete Task',
                            ),
                            onTap: () => _toggleTaskCompletion(task),
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