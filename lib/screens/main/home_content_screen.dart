import 'package:flutter/material.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Content Screen'),
    );
  }
}
