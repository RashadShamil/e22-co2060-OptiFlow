import 'package:flutter/material.dart';
import 'theme.dart';

class MobileNotImplementedScreen extends StatelessWidget {
  final String title;
  const MobileNotImplementedScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MobileTheme.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: const Icon(
                Icons.construction,
                size: 80,
                color: MobileTheme.neonBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Not Implemented',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
