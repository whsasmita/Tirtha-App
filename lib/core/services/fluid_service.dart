import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/fluid_model.dart';

class FluidService {
  Future<FluidBalanceLogResponseDTO> createFluid(CreateOrUpdateFluidLogDTO fluid) async {
    try {
      final response = await ApiClient.dio.post(
        '/fluids', 
        data: fluid.toJson()
      );
      return FluidBalanceLogResponseDTO.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create fluid record: ${e.message}');
    }
  }

  Future<List<FluidBalanceLogResponseDTO>> getFluids() async {
    try {
      final response = await ApiClient.dio.get('/fluids');
      final data = response.data;
      List<dynamic> fluidListData;

      if (data is List) {
        fluidListData = data;
      } 
      else if (data is Map && data['data'] is List) {
        fluidListData = data['data'] as List;
      } else {
        throw Exception('Unexpected response format for getFluids');
      }
      
      return fluidListData
          .map((e) => FluidBalanceLogResponseDTO.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw Exception('Failed to fetch fluids: ${e.message}');
    }
  }
}