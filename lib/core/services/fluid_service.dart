import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/fluid_model.dart';

class FluidService {
  Future<FluidBalanceLogResponseDTO> createFluid(CreateOrUpdateFluidLogDTO fluid) async {
    try {
      print('🚀 Creating fluid log...');
      print('📦 Request: ${fluid.toJson()}');

      final response = await ApiClient.dio.post(
        '/fluids/', 
        data: fluid.toJson(),
        options: Options(
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Raw Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData != null && responseData['data'] != null) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          print('✅ Successfully created fluid log');
          return FluidBalanceLogResponseDTO.fromJson(dataMap);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create fluid record');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create fluid record');
      }
    } on DioException catch (e) {
      print('❌ DioException in createFluid: $e');
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Terjadi kesalahan pada server.');
      }
      throw Exception('Koneksi gagal. Coba lagi nanti.');
    } catch (e) {
      print('❌ Unexpected error in createFluid: $e');
      rethrow;
    }
  }

  Future<List<FluidBalanceLogResponseDTO>> getFluids() async {
    try {
      print('🚀 Fetching fluid logs...');
      
      final response = await ApiClient.dio.get(
        '/fluids/',
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

        List<dynamic> fluidListData = [];

        // ✅ Handle berbagai format response
        if (responseData is List) {
          // Response langsung berupa list
          fluidListData = responseData;
          print('ℹ️ Response is direct list with ${fluidListData.length} items');
        } else if (responseData is Map) {
          // Response berupa object dengan key 'data'
          if (responseData['status'] == 'success' || responseData.containsKey('data')) {
            if (responseData['data'] != null) {
              if (responseData['data'] is List) {
                fluidListData = responseData['data'] as List;
                print('ℹ️ Response has data list with ${fluidListData.length} items');
              } else {
                print('⚠️ Response data is not a list, returning empty list');
                return [];
              }
            } else {
              print('ℹ️ Response data is null, returning empty list');
              return [];
            }
          } else {
            print('⚠️ Response status is not success, returning empty list');
            return [];
          }
        } else {
          print('⚠️ Unexpected response format, returning empty list');
          return [];
        }

        // ✅ Jika list kosong
        if (fluidListData.isEmpty) {
          print('ℹ️ Fluid list is empty, returning empty list');
          return [];
        }

        // ✅ Parse data list
        try {
          final fluids = fluidListData
              .map((e) => FluidBalanceLogResponseDTO.fromJson(e as Map<String, dynamic>))
              .toList();
          
          print('✅ Successfully fetched ${fluids.length} fluid logs');
          return fluids;
        } catch (parseError) {
          print('❌ Error parsing fluid data: $parseError');
          // Jangan throw error, kembalikan list kosong
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
          response.data['message'] ?? 'Failed to fetch fluid logs.',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException in getFluids:');
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
      print('❌ Unexpected error in getFluids: $e');
      
      // ✅ Jangan throw error untuk kasus unexpected
      // Kembalikan empty list agar UI tetap bisa menampilkan "Belum Ada Data"
      print('⚠️ Returning empty list due to unexpected error');
      return [];
    }
  }
}