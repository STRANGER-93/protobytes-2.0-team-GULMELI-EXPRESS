import 'dart:convert';
import 'dart:io';
import '../../../core/api_client.dart';
import '../../../core/models/user_role.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();

  /// Send OTP to the given phone number.
  Future<void> sendOTP(String phone) async {
    try {
      await apiClient.post("/auth/send-otp/", {"phone": phone});
    } catch (e) {
      print("Send OTP Error: $e");
      rethrow;
    }
  }

  /// Verify OTP and get tokens.
  /// For new users (registration), name/role/municipality are required by backend.
  /// Throws [NewUserException] when the phone is not registered yet.
  /// Throws [Exception] on other failures (invalid OTP, server error, etc.).
  Future<AppUser?> verifyOTP({
    required String phone,
    required String otp,
    String? name,
    String? role,
    int? municipality,
  }) async {
    try {
      final res = await apiClient.post("/auth/verify-otp/", {
        "phone": phone,
        "otp": otp,
        if (name != null && name.isNotEmpty) "name": name,
        if (role != null) "role": role,
        if (municipality != null) "municipality": municipality,
      });

      if (res.containsKey('access')) {
        // Persist tokens via api_client
        apiClient.setToken(res['access']);
        apiClient.setRefreshToken(res['refresh'] ?? '');
        // Store user data for auto-login
        if (res['user'] != null) {
          await apiClient.storeUserData(jsonEncode(res['user']));
        }
        return AppUser.fromJson(res);
      }
      return null;
    } catch (e) {
      final msg = e.toString();
      // Backend returns "Name and municipality required for new users"
      // with is_new_user: true when phone is not registered
      if (msg.contains('Name and municipality required') ||
          msg.contains('new user')) {
        throw NewUserException(phone);
      }
      // Re-throw with the actual error message for the UI to display
      rethrow;
    }
  }

  /// Get current user's profile from /auth/profile/
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await apiClient.get("/auth/profile/");
      return res;
    } catch (e) {
      print("Get Profile Error: $e");
      return null;
    }
  }

  /// Update current user's profile (name and/or photo only)
  Future<Map<String, dynamic>?> updateProfile({String? name}) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (body.isEmpty) return null;
      final res = await apiClient.patch("/auth/profile/", body);
      return res;
    } catch (e) {
      print("Update Profile Error: $e");
      return null;
    }
  }

  /// Upload profile photo
  Future<Map<String, dynamic>?> uploadPhoto(String filePath) async {
    try {
      final res = await apiClient.multipartPatch(
        "/auth/profile/",
        files: {'photo': File(filePath)},
      );
      return res;
    } catch (e) {
      print("Upload Photo Error: $e");
      return null;
    }
  }

  /// Get municipalities list for signup
  Future<List<Map<String, dynamic>>> getMunicipalities() async {
    try {
      final res = await apiClient.get("/municipalities/");
      final List<dynamic> data = res is List ? res : res['results'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print("Get Municipalities Error: $e");
      return [];
    }
  }

  Future<void> logout() async {
    apiClient.setToken(null);
    await apiClient.clearTokens();
  }
}

/// Thrown when OTP verification detects an unregistered phone number.
/// The login screen should redirect to signup with the phone pre-filled.
class NewUserException implements Exception {
  final String phone;
  const NewUserException(this.phone);
  @override
  String toString() => 'NewUserException: $phone is not registered';
}
