import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/hemodialysis_model.dart';

class HemodialysisMonitoringService {
  
  /// Create new hemodialysis monitoring
  Future<HemodialysisMonitoringItem> createHemodialysisMonitoring(
    CreateHemodialysisMonitoringDTO monitoring,
  ) async {
    try {
      print('🚀 Creating hemodialysis monitoring...');
      print('📦 Request: ${monitoring.toJson()}');

      final response = await ApiClient.dio.post(
        '/hemodialysis-monitoring/',
        data: monitoring.toJson(),
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📥 Raw Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final itemData = responseData['data'] as Map<String, dynamic>; 
          final item = HemodialysisMonitoringItem.fromJson(itemData);
          
          print('✅ Successfully created monitoring: ${item.toJson()}');
          return item;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create monitoring');
        }
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to create hemodialysis monitoring.',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in createHemodialysisMonitoring: $e');
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Terjadi kesalahan pada server.');
      }
      throw Exception('Koneksi gagal. Coba lagi nanti.');
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Get hemodialysis monitoring history
  Future<List<HemodialysisMonitoringItem>> getHemodialysisMonitoring() async {
    try {
      print('🚀 Fetching hemodialysis monitoring history...');
      
      final response = await ApiClient.dio.get(
        '/hemodialysis-monitoring/history',
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
          validateStatus: (status) => status! < 500, // ✅ Terima semua response < 500
        ),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Raw Response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // ✅ Cek apakah response valid
        if (responseData == null) {
          print('⚠️ Response data is null, returning empty list');
          return [];
        }

        // ✅ Cek status success
        if (responseData['status'] == 'success') {
          // ✅ Cek apakah data ada dan merupakan List
          if (responseData['data'] != null) {
            final dataList = responseData['data'];
            
            // ✅ Jika data bukan List atau kosong, return empty list
            if (dataList is! List) {
              print('⚠️ Data is not a list, returning empty list');
              return [];
            }
            
            if (dataList.isEmpty) {
              print('ℹ️ Data list is empty, returning empty list');
              return [];
            }
            
            // ✅ Parse data list
            try {
              final monitorings = dataList.map((item) {
                return HemodialysisMonitoringItem.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }).toList();
              
              print('✅ Successfully fetched ${monitorings.length} monitoring records');
              return monitorings;
            } catch (parseError) {
              print('❌ Error parsing monitoring data: $parseError');
              // Jangan throw error, kembalikan list kosong
              return [];
            }
          } else {
            // Data null tapi status success, kembalikan empty list
            print('ℹ️ Data is null but status is success, returning empty list');
            return [];
          }
        } else {
          // Status bukan success
          print('⚠️ Response status is not success: ${responseData['status']}');
          return [];
        }
      } else if (response.statusCode == 404) {
        // 404 berarti tidak ada data, bukan error
        print('ℹ️ No data found (404), returning empty list');
        return [];
      } else {
        // Status code lain yang tidak diharapkan
        print('⚠️ Unexpected status code: ${response.statusCode}');
        throw Exception(
          response.data['message'] ?? 'Failed to fetch hemodialysis monitoring.',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in getHemodialysisMonitoring:');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      print('   Error Type: ${e.type}');
      
      // ✅ Jika 404, kembalikan empty list tanpa throw error
      if (e.response?.statusCode == 404) {
        print('ℹ️ 404 Not Found - returning empty list');
        return [];
      }
      
      // ✅ Untuk error jaringan, kembalikan empty list
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        print('⚠️ Network error - returning empty list');
        return [];
      }
      
      // Error lainnya, throw exception
      if (e.response != null && e.response!.data != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Terjadi kesalahan pada server.',
        );
      }
      
      throw Exception('Koneksi gagal. Coba lagi nanti.');
    } catch (e) {
      print('❌ Unexpected error in getHemodialysisMonitoring: $e');
      
      // ✅ Jangan throw error untuk kasus unexpected
      // Kembalikan empty list agar UI tetap bisa menampilkan "Belum Ada Data"
      print('⚠️ Returning empty list due to unexpected error');
      return [];
    }
  }
}