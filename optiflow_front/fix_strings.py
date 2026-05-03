import re

with open('optiflow_front/lib/slices/engine/analytics_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(r'"\$_totalJobs"', '"${_totalJobs}"')
content = content.replace(r'"\${_leadTime.toStringAsFixed(1)} Days"', '"${_leadTime.toStringAsFixed(1)} Days"')
content = content.replace(r'"\${_defectRate.toStringAsFixed(1)}%"', '"${_defectRate.toStringAsFixed(1)}%"')
content = content.replace(r'"\${_oeeScore.toStringAsFixed(0)}%"', '"${_oeeScore.toStringAsFixed(0)}%"')
content = content.replace(r'"\$_totalJobs\nJobs"', '"${_totalJobs}\\nJobs"')

with open('optiflow_front/lib/slices/engine/analytics_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
