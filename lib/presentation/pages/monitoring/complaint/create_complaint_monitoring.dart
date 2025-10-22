import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/core/services/complaint_service.dart';
import 'package:tirtha_app/data/models/complain_model.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class CreateComplaintMonitoring extends StatefulWidget {
  const CreateComplaintMonitoring({Key? key}) : super(key: key);

  @override
  State<CreateComplaintMonitoring> createState() =>
      _CreateComplaintMonitoringState();
}

class _CreateComplaintMonitoringState extends State<CreateComplaintMonitoring> {
  final ComplaintService _complaintService = ComplaintService();
  final List<String> complaints = [
    'Sesak',
    'Nyeri Perut',
    'Pusing',
    'Kaki Bengkak',
    'Lemas',
    'Pendarahan Pasca HD',
    'Bengkak Pada Double Lumen',
  ];

  final Set<String> selectedComplaints = {};
  bool _isLoading = false;

  void _handleReset() {
    setState(() {
      selectedComplaints.clear();
    });
  }

  Future<void> _handleSubmit() async {
    if (selectedComplaints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu keluhan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create complaint object
      final complaint = Complaint(
        complaints: selectedComplaints.toList(),
      );

      // Call API to create complaint - now returns the created complaint with message
      final createdComplaint = await _complaintService.createComplaint(complaint);

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keluhan berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Show dialog with message from API response
      await _showComplaintDialog(createdComplaint);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan keluhan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showComplaintDialog(Complaint complaint) async {
    // Use message from API response, with fallback if null or empty
    final String message = complaint.message != null && complaint.message!.isNotEmpty
        ? complaint.message!
        : 'Konsultasikan keluhan bapak/ibu kepada dokter/perawat yang bertugas';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Perhatian',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.complaintMonitoring,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OKE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BUAT KELUHAN',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: complaints.map((complaint) {
                      final isSelected = selectedComplaints.contains(complaint);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedComplaints.remove(complaint);
                                    } else {
                                      selectedComplaints.add(complaint);
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    complaint,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.secondary
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5A5A5A),
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: const Text(
                          'BUAT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.tertiary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}