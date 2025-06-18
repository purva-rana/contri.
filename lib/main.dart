import 'package:flutter/material.dart';
import 'package:contri/screens/home_screen.dart';

void main() {
  runApp(const ContriApp());
}

class ContriApp extends StatelessWidget {
  const ContriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contri.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}