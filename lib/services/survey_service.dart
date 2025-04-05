import 'dart:io';
import 'package:dio/dio.dart';

class SurveyService {
  static const String baseUrl = 'http://192.168.1.12:3000/api/v1/surveys';
  static const String uploadUrl =
      'http://192.168.1.12:3000/api/v1/files/upload';

  ///

  /// 📌 Fetch daftar survey berdasarkan surveyor_id
  static Future<List<dynamic>> fetchSurveys(String userId) async {
    try {
      Dio dio = Dio();
      Response response = await dio.get(
        '$baseUrl?surveyor_id=$userId',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // 🔥 Debug: Print respons API
        print("✅ Response API Surveys: $data");

        // Jika response adalah Map, ambil dari key 'data'
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final surveyData = data['data'];
          return surveyData is List
              ? surveyData
              : [surveyData]; // Pastikan selalu return List
        }
        // Jika response langsung berupa List
        else if (data is List) {
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
      return []; // Return list kosong agar tidak crash
    }
  }

  /// 📌 Update data survey berdasarkan surveyId
  static Future<void> updateSurvey(
      String surveyId, Map<String, dynamic> data) async {
    try {
      Dio dio = Dio();
      Response response = await dio.patch(
        '$baseUrl/$surveyId',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
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

      FormData formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      Response response = await dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        print("✅ Gambar berhasil diupload: ${response.data}");
        return response.data['file_id']; // Ambil file_id dari response
      } else {
        throw Exception(
            "⚠️ Gagal mengupload gambar (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("❌ Error upload gambar: $e");
      return null; // Return null agar tidak crash
    }
  }
}
