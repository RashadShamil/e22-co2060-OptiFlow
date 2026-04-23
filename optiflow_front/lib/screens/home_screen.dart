import 'package:flutter/material.dart';
import 'resources_screen.dart';
import 'operation_types_screen.dart';
import 'capabilities_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ResourcesScreen(),
    OperationTypesScreen(),
    CapabilitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            backgroundColor: const Color(0xFF1A1A2E),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                Icon(Icons.schedule, color: Colors.white, size: 32),
                SizedBox(height: 6),
                Text('OptiFlow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Slice 4', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.precision_manufacturing_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.precision_manufacturing, color: Colors.white),
                label: Text('Resources', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_alt_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.list_alt, color: Colors.white),
                label: Text('Operations', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.hub_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.hub, color: Colors.white),
                label: Text('Skills Matrix', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
          // Main Content
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}