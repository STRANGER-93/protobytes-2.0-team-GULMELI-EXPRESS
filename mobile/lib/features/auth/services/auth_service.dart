import '../../../core/api_client.dart';
import '../../../core/models/user_role.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();

  /// Send OTP to the given phone number.
  /// Backend only expects {phone} — no role field.
  Future<void> sendOTP(String phone) async {
    try {
      await apiClient.post("/auth/send-otp/", {
        "phone": phone,
      });
    } catch (e) {
      print("Send OTP Error: $e");
      rethrow;
    }
  }

  /// Verify OTP and get tokens.
  /// For new users (registration), name/role/municipality are required by backend.
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
        apiClient.setToken(res['access']);
        return AppUser.fromJson(res);
      }
      return null;
    } catch (e) {
      print("Verify OTP Error: $e");
      return null;
    }
  }

  /// Legacy register method — backend doesn't have this endpoint.
  /// Kept for signup_screen compatibility. Will need refactoring to use OTP flow.
  Future<bool> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      await apiClient.post("/users/register/", {
        "name": fullName,
        "email": email,
        "username": username,
        "password": password,
      });
      return true;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  void logout() {
    apiClient.setToken(null);
  }
}
