import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidasi/services/dio_client.dart';

class ChatbotService {
  static final String apiUrl = "http://192.168.1.4:3000/api/v1/ismart";

  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('session_token') ?? '';
    final csrfToken = prefs.getString('csrf_token') ?? '';

    return {
      "Accept": "application/json",
      "Authorization": "Bearer $sessionToken",
      "X-CSRF-Token": csrfToken,
    };
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

  static Future<String> searchFibernode(String fibernode) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl?fiber_node=$fibernode'),
        headers: headers,
      );

      print("🔵 Status code: ${response.statusCode}");
      print("🔵 Body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['data'] != null && (json['data'] as List).isNotEmpty) {
          final data = json['data'][0];
          final alamat = data['address'] ?? 'Tidak tersedia';
          final koordinat = data['coordinate'] ?? '';
          final locationUrl = "https://www.google.com/maps/place/$koordinat";

          return "Data Fibernode ditemukan:\n"
              "Fibernode: ${data['fiber_node']}\n"
              "Alamat: $alamat\n"
              "Koordinat: $koordinat\n"
              "$locationUrl";
        } else {
          return "Fibernode tidak ditemukan.";
        }
      } else if (response.statusCode == 404) {
        return "Fibernode tidak ditemukan.";
      } else {
        return "Terjadi kesalahan saat mengambil data.";
      }
    } catch (e) {
      print("❌ Error: $e");
      return "Gagal terhubung ke server.";
    }
  }
}
