import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _localUrl = "http://192.168.2.232:8000/api/v1";
  static const String _emulatorUrl = "http://10.0.2.2:8000/api/v1";

  String get baseUrl {
    if (kIsWeb) return _localUrl;
    try {
      if (Platform.isAndroid) return _emulatorUrl;
    } catch (_) {}
    return _localUrl;
  }

  String? _token;
  String? _refreshToken;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  void setToken(String? t) {
    _token = t;
    if (t != null) {
      _storage.write(key: 'access_token', value: t);
    } else {
      _storage.delete(key: 'access_token');
    }
  }

  void setRefreshToken(String? t) {
    _refreshToken = t;
    if (t != null) {
      _storage.write(key: 'refresh_token', value: t);
    } else {
      _storage.delete(key: 'refresh_token');
    }
  }

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  /// Load tokens from secure storage on app startup
  Future<bool> loadStoredTokens() async {
    _token = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    return _token != null;
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_data');
  }

  /// Store user data for auto-login
  Future<void> storeUserData(String jsonStr) async {
    await _storage.write(key: 'user_data', value: jsonStr);
  }

  /// Read stored user data
  Future<String?> readUserData() async {
    return await _storage.read(key: 'user_data');
  }

  Map<String, String> _headers({bool isJson = true}) {
    return {
      if (isJson) "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  /// Attempt to refresh the access token using refresh token
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final url = Uri.parse("$baseUrl/auth/token/refresh/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": _refreshToken}),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newAccess = body['access'] as String?;
        final newRefresh = body['refresh'] as String?;
        if (newAccess != null) {
          setToken(newAccess);
          // Save rotated refresh token if provided
          if (newRefresh != null) {
            setRefreshToken(newRefresh);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var response = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 30));
      }
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.post(
          url,
          headers: _headers(),
          body: jsonEncode(data),
        ).timeout(const Duration(seconds: 30));
      }
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var response = await http.patch(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.patch(
          url,
          headers: _headers(),
          body: jsonEncode(data),
        ).timeout(const Duration(seconds: 30));
      }
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var response = await http.put(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.put(
          url,
          headers: _headers(),
          body: jsonEncode(data),
        ).timeout(const Duration(seconds: 30));
      }
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var response = await http.delete(url, headers: _headers()).timeout(const Duration(seconds: 30));
      if (response.statusCode == 401 && await _tryRefreshToken()) {
        response = await http.delete(url, headers: _headers()).timeout(const Duration(seconds: 30));
      }
      if (response.statusCode == 204) return {"success": true};
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Multipart POST for file uploads
  Future<Map<String, dynamic>> multipartPost(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var request = http.MultipartRequest('POST', url);
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
      if (fields != null) request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 401 && await _tryRefreshToken()) {
        request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $_token';
        if (fields != null) request.fields.addAll(fields);
        if (files != null) {
          for (final entry in files.entries) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }
        streamedResponse = await request.send();
      }

      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Multipart PATCH for file uploads
  Future<Map<String, dynamic>> multipartPatch(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      var request = http.MultipartRequest('PATCH', url);
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
      if (fields != null) request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 401 && await _tryRefreshToken()) {
        request = http.MultipartRequest('PATCH', url);
        request.headers['Authorization'] = 'Bearer $_token';
        if (fields != null) request.fields.addAll(fields);
        if (files != null) {
          for (final entry in files.entries) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }
        streamedResponse = await request.send();
      }

      final response = await http.Response.fromStream(streamedResponse);
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
      if (body is List) return {"results": body};
      return body is Map<String, dynamic> ? body : {"data": body};
    } else {
      final message = body is Map
          ? (body['detail'] ?? body['error'] ?? response.body)
          : response.body;
      throw Exception(message);
    }
  }
}
