import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OperationTypesScreen extends StatefulWidget {
  const OperationTypesScreen({super.key});
  @override
  State<OperationTypesScreen> createState() => _OperationTypesScreenState();
}

class _OperationTypesScreenState extends State<OperationTypesScreen> {
  List<dynamic> opTypes = [];
  bool loading = true;
  final nameCtrl = TextEditingController();

  @override
  void initState() { super.initState(); fetchOpTypes(); }

  Future<void> fetchOpTypes() async {
    setState(() => loading = true);
    opTypes = await ApiService.getOperationTypes();
    setState(() => loading = false);
  }

  Future<void> submitForm() async {
    if (nameCtrl.text.isEmpty) return;
    await ApiService.createOperationType({'name': nameCtrl.text});
    nameCtrl.clear();
    fetchOpTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Operation Types',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const Text('Define all possible actions the print shop can perform',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Card(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Add Operation Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. print_cmyk_a4)',
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: submitForm,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6E56),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ]),
          ]),
        )),
        const SizedBox(height: 24),
        Expanded(child: loading
          ? const Center(child: CircularProgressIndicator())
          : opTypes.isEmpty
              ? const Center(child: Text('No operation types yet.',
                  style: TextStyle(color: Colors.grey)))
              : Card(child: ListView.separated(
                  itemCount: opTypes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final op = opTypes[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE1F5EE),
                        child: Icon(Icons.settings, color: Color(0xFF0F6E56)),
                      ),
                      title: Text(op['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () async {
                          await ApiService.deleteOperationType(op['id']);
                          fetchOpTypes();
                        },
                      ),
                    );
                  },
                )),
        ),
      ]),
    );
  }
}