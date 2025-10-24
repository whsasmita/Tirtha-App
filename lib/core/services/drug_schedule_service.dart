import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/drug_schedule_model.dart';
import 'dart:convert'; // TAMBAHKAN INI

class DrugScheduleService {
  Map<String, dynamic> _parseResponse(dynamic responseData) {
    if (responseData == null) {
      throw Exception('Server returned empty response');
    }

    // If already a Map, return it
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    // If it's a Map but not typed correctly
    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    // If it's a String, try to decode
    if (responseData is String) {
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        throw Exception('Decoded response is not a Map');
      } catch (e) {
        throw Exception('Failed to parse JSON string: $e');
      }
    }

    throw Exception('Unexpected response type: ${responseData.runtimeType}');
  }

  Future<DrugScheduleResponseDTO> createDrugSchedule(CreateDrugScheduleDTO schedule) async {
    try {
      print('🚀 Creating drug schedule...');
      print('📦 Request: ${schedule.toJson()}');
      
      final response = await ApiClient.dio.post(
        '/drug-schedules/',
        data: schedule.toJson(),
      );
      
      print('✅ Status: ${response.statusCode}');
      print('📥 Response Type: ${response.data.runtimeType}');
      
      // Parse response safely
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      print('✅ Parsed as Map');
      
      // Extract data field
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Handle if data is a single object
      if (dataField is Map) {
        return DrugScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField)
        );
      }
      
      // Handle if data is an array (take first item)
      if (dataField is List && dataField.isNotEmpty) {
        return DrugScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField[0])
        );
      }

      throw Exception('Invalid data format in response');
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Status: ${e.response?.statusCode}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid data. Check your input.');
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to create schedule: $e');
    }
  }

  Future<List<DrugScheduleResponseDTO>> getDrugSchedules() async {
    try {
      print('🚀 Fetching drug schedules...');
      
      final response = await ApiClient.dio.get('/drug-schedules');
      
      print('✅ Status: ${response.statusCode}');
      print('📥 Response Type: ${response.data.runtimeType}');
      
      // Parse response safely
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      print('✅ Parsed as Map');
      
      // Extract data field
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Handle if data is a list
      if (dataField is List) {
        return dataField
            .map((item) => DrugScheduleResponseDTO.fromJson(
                  Map<String, dynamic>.from(item)
                ))
            .toList();
      }

      throw Exception('Data field is not a list');
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw Exception('Failed to fetch schedules: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  Future<void> updateDrugSchedule(String id, UpdateDrugScheduleDTO schedule) async {
    try {
      print('🚀 Updating drug schedule ID: $id');
      print('📦 Request: ${schedule.toJson()}');
      
      final response = await ApiClient.dio.put(
        '/drug-schedules/$id',
        data: schedule.toJson(),
      );
      
      print('✅ Status: ${response.statusCode}');
      print('📥 Response Type: ${response.data.runtimeType}');
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw Exception('Failed to update schedule: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> deleteDrugSchedule(String id) async {
    try {
      print('🚀 Deleting drug schedule ID: $id');
      
      final response = await ApiClient.dio.delete(
        '/drug-schedules/$id',
      );
      
      print('✅ Status: ${response.statusCode}');
      print('📥 Response Type: ${response.data.runtimeType}');
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw Exception('Failed to delete schedule: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to delete schedule: $e');
    }
  } 
}