import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Tambahkan ini

class SurveyService {
  static const String baseUrl = 'http://192.168.1.4:3000/api/v1';
  static const String uploadUrl = 'http://192.168.1.4:3000/api/v1/files';

  /// 🔐 Ambil headers dengan session dan CSRF token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('session_token') ?? '';
    final csrfToken = prefs.getString('csrf_token') ?? '';

    print('🔐 Session Token: $sessionToken');
    print('🔐 CSRF Token: $csrfToken');

    return {
      "Accept": "application/json",
      "Authorization": "Bearer $sessionToken",
      "X-CSRF-Token": csrfToken,
    };
  }

  /// 📌 Fetch daftar survey berdasarkan surveyor_id
  static Future<List<dynamic>> fetchSurveys(String userId) async {
    try {
      Dio dio = Dio();
      final headers = await _getAuthHeaders(); // 🔐 Ambil headers

      Response response = await dio.get(
        '$baseUrl/surveys?surveyor_id=$userId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("✅ Response API Surveys: $data");

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final surveyData = data['data'];
          return surveyData is List ? surveyData : [surveyData];
        } else if (data is List) {
          return data;
        } else {
          throw Exception("⚠️ Format response tidak sesuai: $data");
        }
      } else {
        throw Exception(
            "⚠️ Gagal mengambil survey (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("❌ Error fetchSurveys: $e");
      return [];
    }
  }

  /// 📌 Get URL gambar berdasarkan image_id
  static Future<Map<String, dynamic>> getSurveyImageUrl(String imageId) async {
    final headers = await _getAuthHeaders();
    final imageUrl = '$uploadUrl/download?id=$imageId';

    return {
      'url': imageUrl,
      'headers': headers,
    };
  }

  /// 📌 Update data survey berdasarkan surveyId
  static Future<void> updateSurvey(
      String surveyId, Map<String, dynamic> data) async {
    try {
      Dio dio = Dio();
      final headers = await _getAuthHeaders(); // 🔐 Ambil headers

      Response response = await dio.post(
        '$baseUrl/reports', // ✅ tambahkan ID di path
        data: data,
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        print("✅ Survey berhasil diperbarui: $surveyId");
      } else {
        throw Exception(
            "⚠️ Gagal update survey (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("❌ Error update survey: $e");
      throw Exception("Error update survey: $e");
    }
  }

  /// 📌 Upload gambar untuk survey
  static Future<String?> uploadSurveyImage(File imageFile) async {
    try {
      Dio dio = Dio();
      String fileName = imageFile.path.split('/').last;

      // 🔐 Ambil headers dan user_id
      final headers = await _getAuthHeaders();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? ''; // ← ambil author_id

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'author_id': userId, // 🆕 tambahkan author_id
      });

      Response response = await dio.post(
        '$uploadUrl/upload',
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        print("✅ Gambar berhasil diupload: ${response.data}");
        return response.data['data']['id']; // ← id file dari response
      } else {
        throw Exception(
            "⚠️ Gagal mengupload gambar (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("❌ Error upload gambar: $e");
      return null;
    }
  }

  /// 📌 Submit laporan survey lengkap (image wajib)
  static Future<void> submitSurveyReport(
      Map<String, dynamic> reportData) async {
    try {
      final String surveyId = reportData['survey_id'];
      final String? imageId = reportData['image_id'];

      // Cek apakah image sudah diupload
      if (imageId == null || imageId.isEmpty) {
        print("⚠️ Image belum terupload");
        return;
      }

      // Siapkan data untuk update survey
      Map<String, dynamic> updateData = {
        'survey_id': surveyId,
        'result': reportData['status'], // e.g. "standart", "reject"
        'remark': reportData['remark'] ?? '',
        'image_id': imageId,
      };

      await updateSurvey(surveyId, updateData);

      print("✅ submitSurveyReport berhasil untuk surveyId: $surveyId");
    } catch (e) {
      print("❌ Error submitSurveyReport: $e");
      rethrow;
    }
  }
}
