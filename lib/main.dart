import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Convert Task to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority.name,
    };
  }

  // Create Task from stored Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      isCompleted: map['isCompleted'],
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.Medium,
      ),
    );
  }
}

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: TaskListScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const TaskListScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];
  TaskPriority _selectedPriority = TaskPriority.Medium;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load saved tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      setState(() {
        _tasks = decoded.map((taskMap) => Task.fromMap(taskMap)).toList();
      });
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> taskMaps =
        _tasks.map((task) => task.toMap()).toList();
    await prefs.setString('tasks', jsonEncode(taskMaps));
  }

  void _addTask() {
    final taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      setState(() {
        _tasks.add(Task(name: taskName, priority: _selectedPriority));
        _taskController.clear();
        _selectedPriority = TaskPriority.Medium;
      });
      _saveTasks();
    }
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
    _saveTasks();
  }

  void _updateTaskPriority(Task task, TaskPriority newPriority) {
    setState(() {
      task.priority = newPriority;
    });
    _saveTasks();
  }

  int _getPriorityValue(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.High:
        return 0;
      case TaskPriority.Medium:
        return 1;
      case TaskPriority.Low:
        return 2;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.High:
        return Colors.red.shade600;
      case TaskPriority.Medium:
        return Colors.amber.shade700;
      case TaskPriority.Low:
        return Colors.green.shade600;
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Task> sortedTasks = List.from(_tasks);
    sortedTasks.sort(
        (a, b) => _getPriorityValue(a.priority).compareTo(_getPriorityValue(b.priority)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        actions: [
          Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeToggle,
            activeColor: Colors.yellowAccent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
                FilledButton(
                  onPressed: _addTask,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      minimumSize: const Size(60, 50)),
                  child: const Text('Add', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks are added yet!!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
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
                                color: task.isCompleted
                                    ? Colors.grey
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Priority:",
                                  style: TextStyle(
                                    color: _getPriorityColor(task.priority),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<TaskPriority>(
                                    isExpanded: true,
                                    value: task.priority,
                                    style: TextStyle(
                                      color: _getPriorityColor(task.priority),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: TaskPriority.values
                                        .map((TaskPriority value) =>
                                            DropdownMenuItem<TaskPriority>(
                                              value: value,
                                              child: Text(value.name),
                                            ))
                                        .toList(),
                                    onChanged: (TaskPriority? newValue) {
                                      if (newValue != null) {
                                        _updateTaskPriority(task, newValue);
                                      }
                                    },
                                    underline: Container(),
                                  ),
                                ),
                              ],
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
