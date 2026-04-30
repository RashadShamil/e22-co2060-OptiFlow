import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    var content = file.readAsStringSync();
    var newContent = content
        .replaceAll('package:optiflow_scheduler/screens/dashboard/', 'package:optiflow_scheduler/slices/engine/dashboard/')
        .replaceAll('package:optiflow_scheduler/screens/schedule_screen.dart', 'package:optiflow_scheduler/slices/engine/schedule_screen.dart')
        .replaceAll('package:optiflow_scheduler/screens/machines_screen.dart', 'package:optiflow_scheduler/slices/admin/machines_screen.dart')
        .replaceAll('package:optiflow_scheduler/screens/add_machine_screen.dart', 'package:optiflow_scheduler/slices/admin/add_machine_screen.dart')
        .replaceAll('package:optiflow_scheduler/screens/placeholder_screen.dart', 'package:optiflow_scheduler/slices/order/placeholder_screen.dart')
        .replaceAll('package:optiflow_scheduler/mobile/', 'package:optiflow_scheduler/slices/worker/')
        .replaceAll('package:optiflow_scheduler/services/', 'package:optiflow_scheduler/core/services/')
        .replaceAll('package:optiflow_scheduler/models/', 'package:optiflow_scheduler/core/models/')
        .replaceAll('package:optiflow_scheduler/utils/', 'package:optiflow_scheduler/core/utils/');

    if (content != newContent) {
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
    }
  }
}
