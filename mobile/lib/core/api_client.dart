import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiClient {
  // Use http://10.0.2.2:8000 for Android Emulator
  // Use http://127.0.0.1:8000 for local dev (web/windows)
  // IMPORTANT: For physical Android/iOS devices, use your computer's local IP (e.g., 192.168.1.5)
  static const String _localUrl = "http://127.0.0.1:8000/api/v1";
  static const String _emulatorUrl = "http://10.0.2.2:8000/api/v1";

  String get baseUrl {
    if (kIsWeb) return _localUrl;
    try {
      if (Platform.isAndroid) return _emulatorUrl;
    } catch (_) {}
    return _localUrl;
  }
  String? _token;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  void setToken(String? t) => _token = t;
  String? get token => _token;

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.get(url, headers: _headers());
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.patch(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.put(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = {"detail": response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {"data": body};
    } else {
      final message = body is Map ? (body['detail'] ?? body['error'] ?? response.body) : response.body;
      throw Exception(message);
    }
  }
}

