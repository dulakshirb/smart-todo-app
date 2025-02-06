import 'package:dd_smart_todo_app/models/task_model.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/utils/constants.dart';
import 'package:dd_smart_todo_app/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedPriority;
  bool? _isCompleted;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedPriority = null;
      _isCompleted = null;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      final searchMatch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatch =
          _selectedCategory == null || task.categoryId == _selectedCategory;
      final priorityMatch =
          _selectedPriority == null || task.priority == _selectedPriority;
      final statusMatch =
          _isCompleted == null || task.isCompleted == _isCompleted;

      return searchMatch && categoryMatch && priorityMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final categories = Provider.of<CategoryProvider>(context).categories;
    final filteredTasks = _filterTasks(tasks);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          if (_searchQuery.isNotEmpty ||
              _selectedCategory != null ||
              _selectedPriority != null ||
              _isCompleted != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _resetFilters,
            ),
          IconButton(
            icon: Icon(Icons.filter_list,
                color: _showFilters ? Theme.of(context).primaryColor : null),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category.name),
                                  selected: _selectedCategory == category.id,
                                  onSelected: (selected) => setState(() =>
                                      _selectedCategory =
                                          selected ? category.id : null),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: Constants.priorityLevels
                        .map((priority) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(priority.toUpperCase()),
                                selected: _selectedPriority == priority,
                                onSelected: (selected) => setState(() =>
                                    _selectedPriority =
                                        selected ? priority : null),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('In Progress'),
                        selected: _isCompleted == false,
                        onSelected: (selected) => setState(
                            () => _isCompleted = selected ? false : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _isCompleted == true,
                        onSelected: (selected) => setState(
                            () => _isCompleted = selected ? true : null),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Text('No tasks found',
                        style: Theme.of(context).textTheme.titleMedium))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(task: task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
