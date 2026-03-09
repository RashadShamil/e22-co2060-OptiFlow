import 'dart:io';
import 'package:flutter/material.dart';
import 'package:optiflow_scheduler/screens/dashboard/dashboard_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optiflow_scheduler/mobile/mobile_login_screen.dart';

class DesktopEntry extends StatelessWidget {
  const DesktopEntry({super.key});
  @override
  Widget build(BuildContext context) => const DashboardScreen();
}

class MobileEntry extends StatelessWidget {
  const MobileEntry({super.key});
  @override
  Widget build(BuildContext context) => const MobileLoginScreen();
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
