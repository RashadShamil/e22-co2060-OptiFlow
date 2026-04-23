import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OptiFlowApp());
}

class OptiFlowApp extends StatelessWidget {
  const OptiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptiFlow Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const HomeScreen(),
    );
  }
}