import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/screens/auth/auth_screen.dart';
import 'package:smart_todo_app/screens/main/home_screen.dart';
import 'package:smart_todo_app/screens/main/profile_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.data == null) {
              return AuthScreen();
            } else {
              return HomeScreen();
            }
          }),
    );
  }
}
