import 'package:dd_smart_todo_app/providers/auth_provider.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/providers/task_provider.dart';
import 'package:dd_smart_todo_app/screens/auth/auth_wrapper.dart';
import 'package:dd_smart_todo_app/services/notification_service.dart';
import 'package:dd_smart_todo_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProxyProvider<CategoryProvider, TaskProvider>(
          create: (context) => TaskProvider(
            categoryProvider: context.read<CategoryProvider>(),
          ),
          update: (context, categoryProvider, previous) =>
              previous ?? TaskProvider(categoryProvider: categoryProvider),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (auth.currentUser != null) {
                Future.microtask(() {
                  context
                      .read<TaskProvider>()
                      .updateUserId(auth.currentUser!.id);
                  context
                      .read<CategoryProvider>()
                      .updateUserId(auth.currentUser!.id);
                });
              }

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Smart Todo App',
                theme: AppTheme.darakTheme,
                home: const AuthWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}
