import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import 'dart:convert';

class AuthService {
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.1.12:3000/api/v1";

  Future<void> saveTokens(
      String sessionToken, String csrfToken, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', sessionToken);
    await prefs.setString('csrf_token', csrfToken);
    await prefs.setString('user_id', userId);

    print("✅ Session Token Disimpan: $sessionToken");
    print("✅ CSRF Token Disimpan: $csrfToken");
    print("✅ User ID Disimpan: $userId");
  }

  Future<int> login(String email, String password) async {
    try {
      Response response = await _dio.post(
        '$baseUrl/login',
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        var data = response.data['data'];
        String sessionToken = data['session_token'].trim();
        String csrfToken = data['csrf_token'].trim();
        String userId = data['user_id'].trim();

        await saveTokens(sessionToken, csrfToken, userId);

        // Kirim token dan ID ke UserService untuk memastikan data tersimpan
        await UserService().initializeUserData();

        print("✅ Token dan ID berhasil dikirim ke user_service.dart");
        return 200;
      } else {
        print("⚠ Login gagal: ${response.data['message']}");
        return response.statusCode ?? 500;
      }
    } catch (e) {
      print("❌ Error saat login: $e");
      return 500;
    }
  }

  Future<int> register(String name, String callSign, String phone, String email,
      String password, String contractor) async {
    try {
      Map<String, dynamic> requestData = {
        "name": name,
        "call_sign": callSign,
        "phone": phone,
        "email": email,
        "password": password,
        "contractor": contractor,
      };

      print("📡 Data yang dikirim: ${jsonEncode(requestData)}"); // Debugging

      Response response = await _dio.post(
        "$baseUrl/register",
        data: jsonEncode(requestData), // Paksa jadi JSON murni
        options: Options(
          headers: {
            "Content-Type": "application/json", // Pastikan JSON dikirim
          },
        ),
      );
      print("ℹ Register Response Code: ${response.statusCode}");
      return response.statusCode ?? 500;
    } on DioException catch (e) {
      print("❌ Register Error: ${e.response?.statusCode ?? 500}");
      print(
          "❌ Error Data: ${e.response?.data}"); // Tambahkan ini untuk melihat response error
      print(
          "❌ Error Message: ${e.message}"); // Tambahkan ini untuk melihat pesan error
      return e.response?.statusCode ?? 500;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');

    if (sessionToken == null) {
      print("⚠ Tidak ada session token, langsung menghapus data lokal.");
      await prefs.clear();
      return;
    }

    try {
      await _dio.post(
        "$baseUrl/logout",
        options: Options(headers: {
          "Authorization": "Bearer $sessionToken",
        }),
      );
      print("✅ Logout berhasil dari server.");
    } catch (e) {
      print("⚠ Logout Error: $e");
    }

    // Hapus data setelah logout
    await prefs.clear();
    print("✅ Token dan data pengguna telah dihapus dari perangkat.");
  }
}
