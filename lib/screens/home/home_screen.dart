import 'package:dd_smart_todo_app/providers/auth_provider.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/screens/analytics/analytics_screen.dart';
import 'package:dd_smart_todo_app/screens/category/category_form_screen.dart';
import 'package:dd_smart_todo_app/screens/category/category_list_screen.dart';
import 'package:dd_smart_todo_app/screens/profile/profile_screen.dart';
import 'package:dd_smart_todo_app/screens/search/search_screen.dart';
import 'package:dd_smart_todo_app/screens/task/task_form_screen.dart';
import 'package:dd_smart_todo_app/widgets/confirmation_dialog.dart';
import 'package:dd_smart_todo_app/widgets/custom_bottom_nav.dart';
import 'package:dd_smart_todo_app/widgets/task_list.dart';
import 'package:dd_smart_todo_app/widgets/task_stats.dart';
import 'package:dd_smart_todo_app/widgets/user_info_header.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (taskProvider.isLoading || categoryProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: UserInfoHeader()),
                  SizedBox(width: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => const ConfirmationDialog(
                              title: 'Logout',
                              content: 'Are you sure you want to logout?',
                              confirmText: 'Logout',
                              isDestructive: true,
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await context.read<AuthProvider>().signOut();
                          }
                        },
                        icon: const Icon(Icons.logout),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Task Statistics
            if (_currentIndex == 0) const TaskStats(),

            // Main Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  TaskList(tasks: taskProvider.tasks),
                  CategoryListScreen(),
                  AnalyticsScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_$_currentIndex',
        onPressed: () {
          if (_currentIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskFormScreen(),
              ),
            );
          } else if (_currentIndex == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryFormScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskFormScreen(),
              ),
            );
          }
        },
        child: Icon(
          _currentIndex == 0 ? Icons.add_task : Icons.add_circle_outline,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
