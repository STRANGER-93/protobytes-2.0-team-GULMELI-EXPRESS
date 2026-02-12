import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = "http://10.0.2.2:8000/api"; // emulator mapping
  String? token;

  void setToken(String t) => token = t;

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
