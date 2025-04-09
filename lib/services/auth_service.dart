import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:sidasi/services/dio_client.dart';

class AuthService {
  final Dio _dio = Dio();
  final String baseUrl = "http://192.168.1.4:3000/api/v1";
  final CookieJar cookieJar = CookieJar();

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

  AuthService() {
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> fetchUserData(BuildContext context) async {
    try {
      final dio = DioClient.getInstance(context);
      final response = await dio.get('/users?id=123');

      // Gunakan response...
    } catch (e) {
      print("Error saat fetch user: $e");
    }
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
        print("⚠️ Login gagal: ${response.data['message']}");
        return response.statusCode ?? 500;
      }
    } catch (e) {
      print("❌ Error saat login: $e");
      return 500;
    }
  }

  Future<bool> validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('session_token');

    if (sessionToken == null) return false;

    try {
      final response = await _dio.get(
        "$baseUrl/validate",
        options: Options(
          headers: {
            "Authorization": "Bearer $sessionToken",
          },
        ),
      );

      print("✅ Session valid: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Session invalid or error: $e");
      return false;
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
      print("ℹ️ Register Response Code: ${response.statusCode}");
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
      print("⚠️ Tidak ada session token, langsung menghapus data lokal.");
      await prefs.clear();
      return;
    }

    try {
      final response = await _dio.post(
        "$baseUrl/logout",
        options: Options(headers: {
          "Authorization": "Bearer $sessionToken",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Logout berhasil dari server.");
      } else {
        print("⚠️ Logout gagal dari server: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Logout Error: $e");
    }

    // Hapus data lokal setelah logout
    await prefs.clear();
    print("✅ Token dan data pengguna telah dihapus dari perangkat.");
  }
}
