import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});
  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  List<dynamic> resources = [];
  bool loading = true;

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String selectedType = 'MACHINE';
  String selectedStatus = 'ACTIVE';
  String? editingId;

  @override
  void initState() {
    super.initState();
    fetchResources();
  }

  Future<void> fetchResources() async {
    setState(() => loading = true);
    resources = await ApiService.getResources();
    setState(() => loading = false);
  }

  Future<void> submitForm() async {
    final data = {
      'name': nameCtrl.text,
      'type': selectedType,
      'status': selectedStatus,
      'description': descCtrl.text,
    };
    if (editingId != null) {
      await ApiService.updateResource(editingId!, data);
    } else {
      await ApiService.createResource(data);
    }
    clearForm();
    fetchResources();
  }

  void startEdit(dynamic r) {
    setState(() {
      editingId = r['id'];
      nameCtrl.text = r['name'];
      descCtrl.text = r['description'] ?? '';
      selectedType = r['type'];
      selectedStatus = r['status'];
    });
  }

  void clearForm() {
    setState(() {
      editingId = null;
      nameCtrl.clear();
      descCtrl.clear();
      selectedType = 'MACHINE';
      selectedStatus = 'ACTIVE';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Resources', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const Text('Manage machines and human workers', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),

        // Form Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(editingId != null ? 'Edit Resource' : 'Add New Resource',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                )),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: ['MACHINE', 'HUMAN'].map((t) =>
                    DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                )),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: ['ACTIVE', 'IDLE', 'OFFLINE'].map((s) =>
                    DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedStatus = v!),
                )),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: submitForm,
                  icon: Icon(editingId != null ? Icons.save : Icons.add),
                  label: Text(editingId != null ? 'Update' : 'Add Resource'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white),
                ),
                if (editingId != null) ...[
                  const SizedBox(width: 8),
                  TextButton(onPressed: clearForm, child: const Text('Cancel')),
                ]
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(child: loading
          ? const Center(child: CircularProgressIndicator())
          : Card(
            child: ListView.separated(
              itemCount: resources.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = resources[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: r['type'] == 'MACHINE'
                      ? Colors.blue.shade100 : Colors.green.shade100,
                    child: Icon(
                      r['type'] == 'MACHINE' ? Icons.precision_manufacturing : Icons.person,
                      color: r['type'] == 'MACHINE' ? Colors.blue : Colors.green,
                    ),
                  ),
                  title: Text(r['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(r['description'] ?? ''),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: r['status'] == 'ACTIVE' ? Colors.green.shade50
                          : r['status'] == 'IDLE' ? Colors.orange.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(r['status'],
                        style: TextStyle(fontSize: 12,
                          color: r['status'] == 'ACTIVE' ? Colors.green.shade700
                            : r['status'] == 'IDLE' ? Colors.orange.shade700 : Colors.red.shade700)),
                    ),
                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => startEdit(r)),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () async {
                        await ApiService.deleteResource(r['id']);
                        fetchResources();
                      }),
                  ]),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}