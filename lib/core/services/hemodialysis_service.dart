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
            ),
        );

        print('📥 Raw Response: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;

            // Response berisi { "data": {...}, "message": "...", "status": "..." }
            if (responseData['status'] == 'success' && responseData['data'] != null) {
                // PERBAIKAN UTAMA DI SINI
                // Asumsi: responseData['data'] adalah Map (objek tunggal)
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
        // ... (kode penanganan DioException tetap sama)
        rethrow;
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
            ),
        );

        print('📥 Raw Response: ${response.data}');

        if (response.statusCode == 200) {
            final responseData = response.data;
            
            // Asumsi Response berisi { "data": [...], "message": "...", "status": "..." }
            if (responseData['status'] == 'success' && responseData['data'] != null) {
                
                // PERHATIKAN: Pastikan ini adalah List dan di-map dengan benar
                final dataList = responseData['data'] as List; // HARUS LIST
                
                final monitorings = dataList.map((item) {
                    // Setiap item di-cast ke Map<String, dynamic> dan dibuat modelnya
                    return HemodialysisMonitoringItem.fromJson(
                        Map<String, dynamic>.from(item),
                    );
                }).toList();
                
                print('✅ Successfully fetched ${monitorings.length} monitoring records');
                return monitorings; // Mengembalikan list lengkap
            } else {
                // Jika status bukan success atau data null, kembalikan list kosong
                return []; 
            }
        } else {
            // ... (Penanganan status code non-200)
            throw Exception(
                response.data['message'] ?? 'Failed to fetch hemodialysis monitoring.',
            );
        }
    } on DioException catch (e) {
        // ... (Penanganan error)
        rethrow;
    } catch (e) {
        print('❌ Unexpected error in getHemodialysisMonitoring: $e');
        // Jika ada error (seperti type cast error), kembalikan list kosong 
        // atau lempar error agar ditangkap oleh UI
        throw Exception(e.toString());
    }
}
}