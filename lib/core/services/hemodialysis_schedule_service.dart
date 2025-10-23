import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/hemodialysis_schedule_model.dart';

class HemodialysisScheduleService {
  Future<HemodialysisScheduleResponseDTO> createHemodialysisSchedule(CreateHemodialysisScheduleDTO schedule) async {
    try {
      final response = await ApiClient.dio.post(
        '/hemodialysis-schedules', 
        data: schedule.toJson()
      );
      return HemodialysisScheduleResponseDTO.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create hemodialysis schedule: ${e.message}');
    }
  }

  Future<List<HemodialysisScheduleResponseDTO>> getHemodialysisSchedules() async {
    try {
      final response = await ApiClient.dio.get('/hemodialysis-schedules/get');
      final data = response.data;
      List<dynamic> scheduleListData;

      if (data is List) {
        scheduleListData = data;
      } 
      else if (data is Map && data['data'] is List) {
        scheduleListData = data['data'] as List;
      } else {
        throw Exception('Unexpected response format for getHemodialysisSchedules');
      }
      
      return scheduleListData
          .map((e) => HemodialysisScheduleResponseDTO.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw Exception('Failed to fetch hemodialysis schedules: ${e.message}');
    }
  }
}