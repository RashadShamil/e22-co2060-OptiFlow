import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:8000/api';

class ApiService {

  // ─── RESOURCES ───────────────────────────────────────

  static Future<List<dynamic>> getResources() async {
    final res = await http.get(Uri.parse('$baseUrl/resources'));
    return jsonDecode(res.body);
  }

  static Future<void> createResource(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$baseUrl/resources'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> updateResource(String id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse('$baseUrl/resources/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteResource(String id) async {
    await http.delete(Uri.parse('$baseUrl/resources/$id'));
  }

  // ─── OPERATION TYPES ─────────────────────────────────

  static Future<List<dynamic>> getOperationTypes() async {
    final res = await http.get(Uri.parse('$baseUrl/operation-types'));
    return jsonDecode(res.body);
  }

  static Future<void> createOperationType(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$baseUrl/operation-types'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteOperationType(String id) async {
    await http.delete(Uri.parse('$baseUrl/operation-types/$id'));
  }

  // ─── CAPABILITIES ─────────────────────────────────────

  static Future<List<dynamic>> getCapabilities() async {
    final res = await http.get(Uri.parse('$baseUrl/capabilities'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getCapabilitiesByResource(String resourceId) async {
    final res = await http.get(Uri.parse('$baseUrl/capabilities/resource/$resourceId'));
    return jsonDecode(res.body);
  }

  static Future<dynamic> createCapability(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/capabilities'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 400) {
      final err = jsonDecode(res.body);
      throw Exception(err['detail']);
    }
    return jsonDecode(res.body);
  }

  static Future<void> updateCapability(String id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse('$baseUrl/capabilities/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteCapability(String id) async {
    await http.delete(Uri.parse('$baseUrl/capabilities/$id'));
  }
}