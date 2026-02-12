import '../../../core/api_client.dart';

class AuthService {
  final ApiClient apiClient = ApiClient();

  Future<bool> login(String username, String password) async {
    try {
      final res = await apiClient.post("/token/", {
        "username": username,
        "password": password,
      });
      apiClient.setToken(res['access']); // save JWT
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      await apiClient.post("/register/", {
        "full_name": fullName,
        "email": email,
        "username": username,
        "password": password,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
