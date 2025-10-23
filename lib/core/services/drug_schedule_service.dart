import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/drug_schedule_model.dart';

class DrugScheduleService {
  Future<DrugScheduleResponseDTO> createDrugSchedule(CreateDrugScheduleDTO schedule) async {
    try {
      final response = await ApiClient.dio.post(
        '/drug-schedules', 
        data: schedule.toJson()
      );
      return DrugScheduleResponseDTO.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create drug schedule: ${e.message}');
    }
  }

  Future<List<DrugScheduleResponseDTO>> getDrugSchedules() async {
    try {
      final response = await ApiClient.dio.get('/drug-schedules/get');
      final data = response.data;
      List<dynamic> scheduleListData;

      if (data is List) {
        scheduleListData = data;
      } 
      else if (data is Map && data['data'] is List) {
        scheduleListData = data['data'] as List;
      } else {
        throw Exception('Unexpected response format for getDrugSchedules');
      }
      
      return scheduleListData
          .map((e) => DrugScheduleResponseDTO.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw Exception('Failed to fetch drug schedules: ${e.message}');
    }
  }
}