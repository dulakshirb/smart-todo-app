import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/models/task_model.dart';
import 'package:smart_todo_app/providers/task_provider.dart';
import 'package:smart_todo_app/utils/colors.dart';

class TaskScreen extends StatefulWidget {
  final String categoryId;

  const TaskScreen({super.key, required this.categoryId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false)
          .loadTasks(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Scaffold(
        appBar: AppBar(title: Text('Tasks')),
        body: SafeArea(
          child: taskProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : taskProvider.tasks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No tasks available. Please add a new task.',
                          style: TextStyle(color: textColor, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        return _buildTaskCard(task, context);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: backgroundColor,
      elevation: 0,
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 20, color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 15),
            Text(
                'Due: ${task.dueDate.toLocal().toString().split(' ')[0]} ${task.dueTime.format(context)}'),
            const SizedBox(height: 5),
            Text('Priority: ${task.priority}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              activeColor: primaryColor,
              onChanged: (value) {
                final updatedTask = TaskModel(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  dueDate: task.dueDate,
                  dueTime: task.dueTime,
                  priority: task.priority,
                  isCompleted: value ?? false,
                  categoryId: task.categoryId,
                );
                taskProvider.updateTask(updatedTask);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: warningColor),
              onPressed: () =>
                  _confirmDeleteTask(context, task.id, task.categoryId),
            ),
          ],
        ),
        onTap: () {
          _showEditTaskDialog(context, task);
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(
                              'Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (pickedTime != null) {
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 10),
                          Text('Due Time: ${selectedTime.format(context)}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedPriority,
                      items: ['High', 'Medium', 'Low'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedPriority = value!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      final newTask = TaskModel(
                        id: '',
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: selectedDate,
                        dueTime: selectedTime,
                        priority: selectedPriority,
                        isCompleted: false,
                        categoryId: widget.categoryId,
                      );
                      taskProvider.addTask(newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;
    TimeOfDay selectedTime = task.dueTime;
    String selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Text(
                            'Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (pickedTime != null) {
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 10),
                          Text(
                            'Due Time: ${selectedTime.format(context)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedPriority,
                      items: ['High', 'Medium', 'Low'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedPriority = value!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      final updatedTask = TaskModel(
                        id: task.id,
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: selectedDate,
                        dueTime: selectedTime,
                        priority: selectedPriority,
                        isCompleted: task.isCompleted,
                        categoryId: task.categoryId,
                      );
                      taskProvider.updateTask(updatedTask);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTask(
      BuildContext context, String taskId, String categoryId) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                taskProvider.deleteTask(taskId, categoryId);
                Navigator.pop(context);
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
