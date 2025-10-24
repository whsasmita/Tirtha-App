import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/core/services/complaint_service.dart';
import 'package:tirtha_app/data/models/complain_model.dart';
import 'package:tirtha_app/routes/app_routes.dart';

// Assuming AppColors is a class with static const Color members,
// and you have ComplaintService, Complaint model, and AppRoutes defined elsewhere.

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

  /// --- Dialog Handlers ---

  // New: Confirmation Dialog for Reset
  void _handleResetConfirmation() {
    if (selectedComplaints.isEmpty) {
      // No need to confirm if nothing is selected
      _handleReset();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Konfirmasi Reset',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua keluhan yang telah dipilih?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text(
                'TIDAK',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _handleReset(); // Proceed with reset
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('YA, RESET'),
            ),
          ],
        );
      },
    );
  }

  // Original Reset logic
  void _handleReset() {
    setState(() {
      selectedComplaints.clear();
    });
    // Optional: Show a quick feedback snackbar after reset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilihan keluhan telah direset.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // New: Confirmation Dialog for Submit
  void _handleSubmitConfirmation() {
    if (selectedComplaints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu keluhan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Konfirmasi Keluhan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anda telah memilih keluhan berikut:',
              ),
              const SizedBox(height: 8),
              ...selectedComplaints.map((complaint) => Text('- $complaint')).toList(),
              const SizedBox(height: 12),
              const Text(
                'Apakah data ini sudah benar?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text(
                'CEK KEMBALI',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _handleSubmit(); // Proceed with submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('YA, KIRIM'),
            ),
          ],
        );
      },
    );
  }

  // Original Submission logic, modified to call the new success dialog
  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create complaint object
      final complaint = Complaint(
        complaints: selectedComplaints.toList(),
      );

      // Call API to create complaint
      await _complaintService.createComplaint(complaint);

      // --- New: Show an intermediate success popup first ---
      if (!mounted) return;
      await _showIntermediateSuccessDialog();
      // ------------------------------------------------------

      // Determine message based on number of complaints selected
      String message;
      if (selectedComplaints.length == 1) {
        // Jika tercentang satu keluhan
        message = 'Konsultasikan keluhan bapak/ibu kepada dokter/perawat yang bertugas atau hubungi petugas pada link TANYA PETUGAS';
      } else {
        // Jika tercentang lebih dari satu keluhan
        message = 'Segera konsultasikan keluhan bapak/ibu ke poliklinik atau faskes terdekat';
      }

      // Show final guidance dialog
      await _showComplaintDialog(message);

    } catch (e) {
      if (!mounted) return;
      // Show failure message
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

  // New: Intermediate Success Dialog
  Future<void> _showIntermediateSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Berhasil!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Keluhan berhasil disimpan',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog, proceed to next step
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'LANJUT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Original Final Guidance Dialog
  Future<void> _showComplaintDialog(String message) async {
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
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // This is the final step, redirecting
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.complaintMonitoring,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
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
            ),
          ],
        );
      },
    );
  }

  /// --- Widget Build Method ---

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
                        // Use the confirmation handler
                        onPressed: _isLoading ? null : _handleResetConfirmation,
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
                        // Use the confirmation handler
                        onPressed: _isLoading ? null : _handleSubmitConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}