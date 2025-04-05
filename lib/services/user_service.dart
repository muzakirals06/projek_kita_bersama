import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.1.12:3000/api/v1";

  // ✅ Menyimpan data user setelah login
  Future<void> initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    String? sessionToken = prefs.getString("session_token");
    String? csrfToken = prefs.getString("csrf_token");

    if (userId == null || sessionToken == null || csrfToken == null) {
      print("❌ Token atau User ID tidak ditemukan di SharedPreferences!");
      return;
    }

    print("📌 Token dan ID berhasil didapatkan:");
    print("🔑 User ID: $userId");
    print("🔑 Session Token: $sessionToken");
    print("🔑 CSRF Token: $csrfToken");
  }

  // ✅ Mengambil data user berdasarkan user ID
  Future<Map<String, dynamic>?> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    String? sessionToken = prefs.getString("session_token");
    String? csrfToken = prefs.getString("csrf_token");

    if (userId == null || sessionToken == null || csrfToken == null) {
      print("❌ Tidak dapat mengambil data user: Token atau ID kosong!");
      return null;
    }

    try {
      Response response = await _dio.get(
        "$baseUrl/users?id=$userId",
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $sessionToken",
            "X-CSRF-Token": csrfToken,
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['code'] == 200 && responseData['status'] == "Ok") {
          print("✅ Data user berhasil didapatkan:");
          print(responseData['data']);
          return responseData['data'];
        } else {
          print("⚠ API mengembalikan kode: ${responseData['code']}");
          print("⚠ Pesan error: ${responseData['message']}");
          return null;
        }
      } else {
        print("⚠ API mengembalikan kode: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error mengambil data user: $e");
      return null;
    }
  }
}
