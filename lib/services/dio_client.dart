import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.12:3000/api/v1', // Sesuaikan dengan API-mu
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      "Accept": "application/json",
    },
    extra: {
      "withCredentials": true, // ✅ Tambahkan ini untuk CORS
    },
  ));

  static Dio getInstance() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("🔍 [REQUEST] ${options.method} ${options.uri}");
        print("📝 Headers: ${options.headers}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ [RESPONSE] ${response.statusCode}");
        print(response.data);
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ [ERROR] ${e.response?.statusCode}");
        print(e.response?.data);
        return handler.next(e);
      },
    ));
    return _dio;
  }
}
