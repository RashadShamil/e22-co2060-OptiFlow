import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CapabilitiesScreen extends StatefulWidget {
  const CapabilitiesScreen({super.key});
  @override
  State<CapabilitiesScreen> createState() => _CapabilitiesScreenState();
}

class _CapabilitiesScreenState extends State<CapabilitiesScreen> {
  List<dynamic> capabilities = [];
  List<dynamic> resources = [];
  List<dynamic> opTypes = [];
  bool loading = true;
  String? selectedResource;
  String? selectedOpType;
  final speedCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() => loading = true);
    capabilities = await ApiService.getCapabilities();
    resources = await ApiService.getResources();
    opTypes = await ApiService.getOperationTypes();
    setState(() => loading = false);
  }

  Future<void> submitForm() async {
    setState(() => errorMsg = null);
    try {
      await ApiService.createCapability({
        'resource_id': selectedResource,
        'operation_type_id': selectedOpType,
        'processing_rate_per_hr': double.parse(speedCtrl.text),
        'setup_time_minutes': 0,
        'cost_per_hour': double.parse(costCtrl.text),
      });
      speedCtrl.clear();
      costCtrl.clear();
      setState(() {
        selectedResource = null;
        selectedOpType = null;
      });
      fetchAll();
    } catch (e) {
      setState(() => errorMsg = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Header
        const Text('Skills Matrix',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const Text('Assign capabilities to resources with speed and cost',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),

        // Form Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const Text('Assign Capability',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),

              // Error message
              if (errorMsg != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(errorMsg!,
                      style: TextStyle(color: Colors.red.shade700)),
                ),

              // Form Row
              Row(children: [

                // Resource Dropdown
                Expanded(child: DropdownMenu<String>(
                  width: double.infinity,
                  label: const Text('Resource'),
                  onSelected: (v) => setState(() => selectedResource = v),
                  dropdownMenuEntries: resources
                      .map<DropdownMenuEntry<String>>((r) =>
                          DropdownMenuEntry(
                            value: r['id'],
                            label: r['name'],
                          ))
                      .toList(),
                )),
                const SizedBox(width: 12),

                // Operation Type Dropdown
                Expanded(child: DropdownMenu<String>(
                  width: double.infinity,
                  label: const Text('Operation Type'),
                  onSelected: (v) => setState(() => selectedOpType = v),
                  dropdownMenuEntries: opTypes
                      .map<DropdownMenuEntry<String>>((op) =>
                          DropdownMenuEntry(
                            value: op['id'],
                            label: op['name'],
                          ))
                      .toList(),
                )),
                const SizedBox(width: 12),

                // Units per hour
                Expanded(child: TextField(
                  controller: speedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Units per hour',
                    border: OutlineInputBorder(),
                  ),
                )),
                const SizedBox(width: 12),

                // Hourly cost
                Expanded(child: TextField(
                  controller: costCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hourly cost (\$)',
                    border: OutlineInputBorder(),
                  ),
                )),
              ]),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton.icon(
                onPressed: (selectedResource != null && selectedOpType != null)
                    ? submitForm
                    : null,
                icon: const Icon(Icons.link),
                label: const Text('Assign Capability'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF534AB7),
                  foregroundColor: Colors.white,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // Capabilities List
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : capabilities.isEmpty
                  ? const Center(
                      child: Text('No capabilities assigned yet.',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : Card(
                      child: ListView.separated(
                        itemCount: capabilities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final c = capabilities[i];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEEEDFE),
                              child: Icon(Icons.hub, color: Color(0xFF534AB7)),
                            ),
                            title: Text(
                              '${c['resources']?['name'] ?? 'Unknown'} → ${c['operation_types']?['name'] ?? 'Unknown'}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                                '${c['processing_rate_per_hr']} units/hr  •  \$${c['cost_per_hour']}/hr'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.red),
                              onPressed: () async {
                                await ApiService.deleteCapability(c['id']);
                                fetchAll();
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}