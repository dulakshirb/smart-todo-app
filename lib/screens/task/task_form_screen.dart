import 'package:dd_smart_todo_app/models/category_model.dart';
import 'package:dd_smart_todo_app/models/task_model.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/utils/constants.dart';
import 'package:dd_smart_todo_app/utils/date_utils.dart';
import 'package:dd_smart_todo_app/widgets/custom_button.dart';
import 'package:dd_smart_todo_app/widgets/custom_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedPriority;
  CategoryModel? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController =
        TextEditingController(text: widget.task?.description);
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _selectedTime = widget.task?.dueTime != null
        ? TimeOfDay(
            hour: int.parse(widget.task!.dueTime.split(':')[0]),
            minute: int.parse(widget.task!.dueTime.split(':')[1]),
          )
        : TimeOfDay.now();
    _selectedPriority = widget.task?.priority ?? 'medium';

    // Set initial category if editing a task
    if (widget.task != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final categories =
              Provider.of<CategoryProvider>(context, listen: false).categories;
          _selectedCategory = categories.firstWhere(
            (category) => category.id == widget.task!.categoryId,
            orElse: () {
              final userId = Provider.of<AuthProvider>(context, listen: false)
                  .currentUser!
                  .id;
              return Constants.getUncategorizedCategory(userId);
            },
          );
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

      final categoryId = _selectedCategory?.id ??
          Constants.getUncategorizedCategory(userId).id;

      final task = TaskModel(
        id: widget.task?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: userId,
        categoryId: categoryId,
        dueDate: _selectedDate,
        dueTime:
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        priority: _selectedPriority,
        isCompleted: widget.task?.isCompleted ?? false,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.task != null) {
        await Provider.of<TaskProvider>(context, listen: false)
            .updateTask(task);
      } else {
        await Provider.of<TaskProvider>(context, listen: false)
            .createTask(task);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCategoryChip(CategoryModel category,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _selectedCategory?.id == category.id
              ? category.color.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: category.color,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: category.color,
            ),
            const SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                color: category.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due Date & Time
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateTimeUtils.formatDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Time',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Priority
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CustomChip(
                        label: 'Low',
                        isSelected: _selectedPriority == 'low',
                        onTap: () => setState(() => _selectedPriority = 'low'),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      CustomChip(
                        label: 'Medium',
                        isSelected: _selectedPriority == 'medium',
                        onTap: () =>
                            setState(() => _selectedPriority = 'medium'),
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      CustomChip(
                        label: 'High',
                        isSelected: _selectedPriority == 'high',
                        onTap: () => setState(() => _selectedPriority = 'high'),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Uncategorized option
                      _buildCategoryChip(
                        Constants.getUncategorizedCategory(userId),
                        onTap: () {
                          setState(() => _selectedCategory =
                              Constants.getUncategorizedCategory(userId));
                        },
                      ),
                      // User categories
                      ...categories.map((category) => _buildCategoryChip(
                            category,
                            onTap: () {
                              setState(() => _selectedCategory = category);
                            },
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            CustomButton(
              text: widget.task != null ? 'Update Task' : 'Create Task',
              onPressed: _saveTask,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
