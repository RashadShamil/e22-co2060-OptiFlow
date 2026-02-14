import 'dart:io';
import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/screens/dashboard/dashboard_screen.dart';

class DesktopEntry extends StatelessWidget {
  const DesktopEntry({super.key});
  @override
  Widget build(BuildContext context) => const DashboardScreen();
}

class MobileEntry extends StatelessWidget {
  const MobileEntry({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Mobile Login")));
}

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Opti',
      theme: ThemeData(primarySwatch: Colors.blue),
      // THE MAGIC SWITCH
      home: (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
          ? const DesktopEntry()
          : const MobileEntry(),
    );
  }
}