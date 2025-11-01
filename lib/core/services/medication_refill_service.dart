import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'dart:convert';
import 'package:tirtha_app/data/models/medication_refill_model.dart';

class MedicationRefillService {
  // Utility: Diperkuat untuk menangani respons non-JSON pada status sukses (kosong)
  Map<String, dynamic> _parseResponse(dynamic responseData) {
    if (responseData == null || (responseData is String && responseData.trim().isEmpty)) {
      // Menangani kasus respons kosong (null atau string kosong) yang sering menyebabkan FormatException.
      throw Exception('Server returned empty or non-JSON response.'); 
    }

    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String) {
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        throw Exception('Decoded response is not a Map');
      } catch (e) {
        // Ini adalah tempat FormatException yang Anda alami terlempar.
        throw Exception('Failed to parse JSON string: $e');
      }
    }

    throw Exception('Unexpected response type: ${responseData.runtimeType}');
  }

  // ------------------------------------
  // 1. GET ALL: /medication-refills
  // ------------------------------------
  Future<List<MedicationRefillResponseDTO>> getRefillSchedules() async {
    try {
      final response = await ApiClient.dio.get('/medication-refills/');
      
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      if (dataField is List) {
        return dataField
            .map((item) => MedicationRefillResponseDTO.fromJson(
                  Map<String, dynamic>.from(item)
                ))
            .toList();
      }

      throw Exception('Data field is not a list');
      
    } on DioException catch (e) {
      throw Exception('Failed to fetch refill schedules: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch refill schedules: $e');
    }
  }

  // ------------------------------------
  // 2. GET BY ID: /medication-refills/{id}
  // ------------------------------------
  Future<MedicationRefillResponseDTO> getRefillScheduleById(int id) async {
    try {
      final response = await ApiClient.dio.get('/medication-refills/$id');
      
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];

      if (dataField is Map) {
        return MedicationRefillResponseDTO.fromJson(
            Map<String, dynamic>.from(dataField));
      }
      
      throw Exception('Invalid data format in response');

    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Refill schedule not found');
      }
      throw Exception('Failed to fetch refill schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch refill schedule: $e');
    }
  }

  // ------------------------------------
  // 3. POST: /medication-refills (CREATE)
  // ------------------------------------
  Future<MedicationRefillResponseDTO> createRefillSchedule(
    CreateMedicationRefillDTO schedule,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/medication-refills/',
        data: schedule.toJson(),
      );
      
      // 🔥 Pengecekan: Jika API sukses (201/200) tetapi body-nya kosong
      if (response.data == null || (response.data is String && (response.data as String).trim().isEmpty)) {
          throw Exception('Operation success but server returned an empty body. Cannot retrieve created data.');
      }
      
      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Asumsi API mengembalikan objek tunggal yang baru dibuat di dalam field 'data'
      if (dataField is Map) {
        return MedicationRefillResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField),
        );
      }
      
      throw Exception('Invalid data format in response');

    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid data. Check your input.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Pesan error dari _parseResponse akan muncul di sini jika JSON tidak valid
      throw Exception('Failed to create refill schedule: $e');
    }
  }

  // ------------------------------------
  // 4. PUT: /medication-refills/{id} (UPDATE)
  // ------------------------------------
  Future<MedicationRefillResponseDTO> updateRefillSchedule(
    int id,
    UpdateMedicationRefillDTO schedule,
  ) async {
    try {
      final response = await ApiClient.dio.put(
        '/medication-refills/$id',
        data: schedule.toJson(),
      );
      
      // 🔥 Pengecekan: Jika API sukses (200) tetapi body-nya kosong
      if (response.data == null || (response.data is String && (response.data as String).trim().isEmpty)) {
        throw Exception('Server returned success (200) but no data to parse after update.');
      }

      final Map<String, dynamic> responseMap = _parseResponse(response.data);
      
      if (!responseMap.containsKey('data')) {
        throw Exception('Response missing "data" field');
      }

      final dynamic dataField = responseMap['data'];
      
      // Asumsi API mengembalikan objek yang diperbarui
      if (dataField is Map) {
        return MedicationRefillResponseDTO.fromJson(
          Map<String, dynamic>.from(dataField),
        );
      }
      
      throw Exception('Invalid data format in response');
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Refill schedule not found');
      }
      throw Exception('Failed to update refill schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update refill schedule: $e');
    }
  }

  // ------------------------------------
  // 5. DELETE: /medication-refills/{id}
  // ------------------------------------
  Future<void> deleteRefillSchedule(int id) async {
    try {
      // Operasi DELETE seringkali mengembalikan 204 No Content (body kosong)
      await ApiClient.dio.delete('/medication-refills/$id');
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Refill schedule not found');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You are not authorized to delete this schedule');
      }
      
      throw Exception('Failed to delete refill schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete refill schedule: $e');
    }
  }
}