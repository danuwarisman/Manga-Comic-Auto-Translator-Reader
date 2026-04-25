import 'package:dio/dio.dart';
import 'package:frontend/models/translation_model.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:8000'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  /// Upload image for OCR processing using the current backend MVP API.
  Future<TranslationResult> uploadFile(
    String filePath, {
    String language = 'english',
  }) async {
    try {
      final file = await MultipartFile.fromFile(filePath);
      final formData = FormData.fromMap({
        'file': file,
        'target_language': language,
      });

      final response = await _dio.post(
        '/api/translate/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TranslationResult.fromJson(response.data);
      }

      throw Exception('Upload failed: ${response.statusMessage}');
    } on DioException catch (e) {
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['detail']?.toString() ?? e.message)
          : e.message;
      throw Exception('Upload error: $detail');
    }
  }

  /// Get backend health status.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/api/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
