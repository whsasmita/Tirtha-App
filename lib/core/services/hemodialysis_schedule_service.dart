import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/hemodialysis_schedule_model.dart';
import 'dart:convert';

class HemodialysisScheduleService {
  Map<String, dynamic> _parseResponse(dynamic responseData) {
    if (responseData == null) {
      print('⚠️ Response data is NULL');
      throw Exception('Server returned empty response');
    }

    print('🔍 Parsing response of type: ${responseData.runtimeType}');

    // If already a Map, return it
    if (responseData is Map<String, dynamic>) {
      print('✅ Already Map<String, dynamic>');
      return responseData;
    }

    // If it's a Map but not typed correctly
    if (responseData is Map) {
      print('✅ Converting Map to Map<String, dynamic>');
      return Map<String, dynamic>.from(responseData);
    }

    // If it's a String, try to decode
    if (responseData is String) {
      print('⚠️ Response is String, attempting to decode...');
      print('📄 String content: $responseData');
      
      if (responseData.trim().isEmpty) {
        throw Exception('Response is empty string');
      }
      
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map) {
          print('✅ Successfully decoded JSON string to Map');
          return Map<String, dynamic>.from(decoded);
        }
        throw Exception('Decoded response is not a Map');
      } catch (e) {
        print('❌ Failed to parse JSON: $e');
        throw Exception('Failed to parse JSON string: $e');
      }
    }

    print('❌ Unexpected type: ${responseData.runtimeType}');
    throw Exception('Unexpected response type: ${responseData.runtimeType}');
  }

  Future<HemodialysisScheduleResponseDTO> createHemodialysisSchedule(
    CreateHemodialysisScheduleDTO schedule,
  ) async {
    try {
      print('🚀 Creating hemodialysis schedule...');
      print('📦 Request: ${schedule.toJson()}');
      
      final response = await ApiClient.dio.post(
        '/hemodialysis-schedules/',
        data: schedule.toJson(),
      );
      
      print('✅ Status: ${response.statusCode}');
      print('📥 Response Type: ${response.data.runtimeType}');
      print('📥 Raw Response Data: ${response.data}');
      
      // Parse response safely
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      print('✅ Parsed as Map');
      print('📥 Response Map: $responseMap');
      
      // Extract data field
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Handle if data is a single object
      if (dataField is Map) {
        return HemodialysisScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField)
        );
      }
      
      // Handle if data is an array (take first item)
      if (dataField is List && dataField.isNotEmpty) {
        return HemodialysisScheduleResponseDTO.fromJson(
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
      throw Exception('Failed to create hemodialysis schedule: $e');
    }
  }

  Future<List<HemodialysisScheduleResponseDTO>> getHemodialysisSchedules() async {
    try {
      print('🚀 Fetching hemodialysis schedules...');
      
      final response = await ApiClient.dio.get('/hemodialysis-schedules');
      
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
            .map((item) => HemodialysisScheduleResponseDTO.fromJson(
                  Map<String, dynamic>.from(item)
                ))
            .toList();
      }

      throw Exception('Data field is not a list');
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw Exception('Failed to fetch hemodialysis schedules: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to fetch hemodialysis schedules: $e');
    }
  }

  Future<HemodialysisScheduleResponseDTO> updateHemodialysisSchedule(
    int id,
    UpdateHemodialysisScheduleDTO schedule,
  ) async {
    try {
      print('🚀 Updating hemodialysis schedule ID: $id');
      print('📦 Request: ${schedule.toJson()}');
      
      final response = await ApiClient.dio.put(
        '/hemodialysis-schedules/$id',
        data: schedule.toJson(),
      );
      
      print('✅ Status: ${response.statusCode}');
      
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      if (dataField is Map) {
        return HemodialysisScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField)
        );
      }
      
      throw Exception('Invalid data format in response');
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw Exception('Failed to update hemodialysis schedule: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to update hemodialysis schedule: $e');
    }
  }

  Future<void> deleteHemodialysisSchedule(int id) async {
    try {
      print('🚀 Deleting hemodialysis schedule ID: $id');
      
      final response = await ApiClient.dio.delete('/hemodialysis-schedules/$id');
      
      print('✅ Hemodialysis schedule deleted successfully');
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      
      if (e.response?.statusCode == 403) {
        throw Exception('You are not authorized to delete this schedule');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Hemodialysis schedule not found');
      }
      
      throw Exception('Failed to delete hemodialysis schedule: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to delete hemodialysis schedule: $e');
    }
  }
}