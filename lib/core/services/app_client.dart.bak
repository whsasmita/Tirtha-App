import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://tirtapp.fmews.com/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Accept any status code less than 500
        return status != null && status < 500;
      },
    ),
  );
  
  static final _storage = const FlutterSecureStorage();

  static void init() {
    // Response Interceptor - Handle String responses
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          print('🌐 ${options.method} ${options.path}');
          if (options.data != null) {
            print('📤 Request: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ ${response.statusCode} ${response.requestOptions.path}');
          print('📥 Response Type: ${response.data.runtimeType}');
          
          // Auto-convert String to JSON if possible
          if (response.data is String) {
            final String dataStr = (response.data as String).trim();
            if (dataStr.startsWith('{') || dataStr.startsWith('[')) {
              try {
                response.data = jsonDecode(dataStr);
                print('🔄 Auto-decoded JSON string');
              } catch (e) {
                print('⚠️ Could not decode: $e');
              }
            }
          }
          
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Error ${error.response?.statusCode}: ${error.message}');
          if (error.response?.data != null) {
            print('❌ Response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );

    // Optional: Add logging interceptor for debugging
    // Uncomment if you need detailed logs
    // dio.interceptors.add(
    //   LogInterceptor(
    //     requestBody: true,
    //     responseBody: true,
    //     error: true,
    //     logPrint: (obj) => print(obj),
    //   ),
    // );
  }
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}