import os

replacements = {
    'package:optiflow_scheduler/screens/dashboard/': 'package:optiflow_scheduler/slices/engine/',
    'package:optiflow_scheduler/screens/schedule_screen.dart': 'package:optiflow_scheduler/slices/engine/schedule_screen.dart',
    'package:optiflow_scheduler/screens/machines_screen.dart': 'package:optiflow_scheduler/slices/admin/machines_screen.dart',
    'package:optiflow_scheduler/screens/add_machine_screen.dart': 'package:optiflow_scheduler/slices/admin/add_machine_screen.dart',
    'package:optiflow_scheduler/screens/placeholder_screen.dart': 'package:optiflow_scheduler/slices/order/placeholder_screen.dart',
    'package:optiflow_scheduler/mobile/': 'package:optiflow_scheduler/slices/worker/',
    'package:optiflow_scheduler/services/': 'package:optiflow_scheduler/core/services/',
    'package:optiflow_scheduler/models/': 'package:optiflow_scheduler/core/models/',
    'package:optiflow_scheduler/utils/': 'package:optiflow_scheduler/core/utils/'
}

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            new_content = content
            for old, new in replacements.items():
                new_content = new_content.replace(old, new)
            if content != new_content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated {path}")
