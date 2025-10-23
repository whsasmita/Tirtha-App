import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/control_schedule_model.dart';

class ControlScheduleService {
  Future<ControlScheduleResponseDTO> createControlSchedule(CreateControlScheduleDTO schedule) async {
    try {
      final response = await ApiClient.dio.post(
        '/control-schedules', 
        data: schedule.toJson()
      );
      return ControlScheduleResponseDTO.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create control schedule: ${e.message}');
    }
  }

  Future<List<ControlScheduleResponseDTO>> getControlSchedules() async {
    try {
      final response = await ApiClient.dio.get('/control-schedules/get');
      final data = response.data;
      List<dynamic> scheduleListData;

      if (data is List) {
        scheduleListData = data;
      } 
      else if (data is Map && data['data'] is List) {
        scheduleListData = data['data'] as List;
      } else {
        throw Exception('Unexpected response format for getControlSchedules');
      }
      
      return scheduleListData
          .map((e) => ControlScheduleResponseDTO.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw Exception('Failed to fetch control schedules: ${e.message}');
    }
  }
}