import 'package:dio/dio.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/complain_model.dart';

class ComplaintService {
   Future<Complaint> createComplaint(Complaint complaint) async {
    try {
      final response = await ApiClient.dio.post(
        '/complaints/', 
        data: complaint.toCreateJson()
      );
      return Complaint.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create complaint: ${e.message}');
    }
  }

  Future<List<Complaint>> getComplaints() async {
    try {
      final response = await ApiClient.dio.get('/complaints/');
      final data = response.data;
      List<dynamic> complaintListData;

      if (data is List) {
        complaintListData = data;
      } 
      else if (data is Map && data['data'] is List) {
        complaintListData = data['data'] as List;
      } else {
        throw Exception('Unexpected response format for getComplaints');
      }
      
      return complaintListData
          .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
          .toList();

    } on DioException catch (e) {
      throw Exception('Failed to fetch complaints: ${e.message}');
    }
  }

  Future<Complaint> getComplaintsById(String id) async {
    try {
      final response = await ApiClient.dio.get('/complaints/$id');
      return Complaint.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch complaint with id $id: ${e.message}');
    }
  }
}