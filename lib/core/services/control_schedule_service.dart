import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/control_schedule_model.dart';
import 'dart:convert';

class ControlScheduleService {
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

  Future<ControlScheduleResponseDTO> createControlSchedule(
    CreateControlScheduleDTO schedule,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/control-schedules/',
        data: schedule.toJson(),
      );
      
      // Parse response safely
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      // Extract data field
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Handle if data is a single object
      if (dataField is Map) {
        return ControlScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField)
        );
      }
      
      // Handle if data is an array (take first item)
      if (dataField is List && dataField.isNotEmpty) {
        return ControlScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField[0])
        );
      }

      throw Exception('Invalid data format in response');
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid data. Check your input.');
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create control schedule: $e');
    }
  }

  Future<List<ControlScheduleResponseDTO>> getControlSchedules() async {
    try {
      final response = await ApiClient.dio.get('/control-schedules');
      
      // Parse response safely
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      // Extract data field
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Handle if data is a list
      if (dataField is List) {
        return dataField
            .map((item) => ControlScheduleResponseDTO.fromJson(
                  Map<String, dynamic>.from(item)
                ))
            .toList();
      }

      throw Exception('Data field is not a list');
      
    } on DioException catch (e) {
      throw Exception('Failed to fetch control schedules: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch control schedules: $e');
    }
  }

  Future<ControlScheduleResponseDTO> updateControlSchedule(
    int id,
    UpdateControlScheduleDTO schedule,
  ) async {
    try {
      final response = await ApiClient.dio.put(
        '/control-schedules/$id',
        data: schedule.toJson(),
      );
      
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      if (dataField is Map) {
        return ControlScheduleResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField)
        );
      }
      
      throw Exception('Invalid data format in response');
      
    } on DioException catch (e) {
      throw Exception('Failed to update control schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update control schedule: $e');
    }
  }

  Future<void> deleteControlSchedule(int id) async {
    try {
      // final response = await ApiClient.dio.delete('/control-schedules/$id');
      
      } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('You are not authorized to delete this schedule');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Control schedule not found');
      }
      
      throw Exception('Failed to delete control schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete control schedule: $e');
    }
  }
}
