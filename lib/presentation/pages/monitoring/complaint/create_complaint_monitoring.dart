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

  // Untuk input dinamis
  final List<TextEditingController> _customControllers = [];
  final List<FocusNode> _customFocusNodes = [];

  @override
  void dispose() {
    // Bersihkan semua controller dan focus node
    for (var controller in _customControllers) {
      controller.dispose();
    }
    for (var focusNode in _customFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// --- Custom Input Handlers ---

  void _addCustomInput() {
    setState(() {
      _customControllers.add(TextEditingController());
      _customFocusNodes.add(FocusNode());
    });
    // Fokus ke input baru
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_customFocusNodes.isNotEmpty) {
        _customFocusNodes.last.requestFocus();
      }
    });
  }

  void _removeCustomInput(int index) {
    setState(() {
      _customControllers[index].dispose();
      _customFocusNodes[index].dispose();
      _customControllers.removeAt(index);
      _customFocusNodes.removeAt(index);
    });
  }

  /// --- Dialog Handlers ---

  void _handleResetConfirmation() {
    if (selectedComplaints.isEmpty && _customControllers.isEmpty) {
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
            'Apakah Anda yakin ingin menghapus semua keluhan yang telah dipilih dan input keluhan lainnya?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'TIDAK',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleReset();
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

  void _handleReset() {
    setState(() {
      selectedComplaints.clear();
      // Hapus semua input custom
      for (var controller in _customControllers) {
        controller.dispose();
      }
      for (var focusNode in _customFocusNodes) {
        focusNode.dispose();
      }
      _customControllers.clear();
      _customFocusNodes.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilihan keluhan telah direset.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleSubmitConfirmation() {
    // Kumpulkan semua keluhan (dari checklist + custom input)
    List<String> allComplaints = selectedComplaints.toList();
    
    // Tambahkan keluhan custom yang sudah diisi
    for (var controller in _customControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        allComplaints.add(text);
      }
    }

    if (allComplaints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu keluhan atau tambahkan keluhan lainnya'),
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
              ...allComplaints.map((complaint) => Text('- $complaint')).toList(),
              const SizedBox(height: 12),
              const Text(
                'Apakah data ini sudah benar?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CEK KEMBALI',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubmit(allComplaints);
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

  Future<void> _handleSubmit(List<String> allComplaints) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final complaint = Complaint(
        complaints: allComplaints,
      );

      await _complaintService.createComplaint(complaint);

      if (!mounted) return;
      await _showIntermediateSuccessDialog();

      String message;
      if (allComplaints.length == 1) {
        message = 'Konsultasikan keluhan bapak/ibu kepada dokter/perawat yang bertugas atau hubungi petugas pada link TANYA PETUGAS';
      } else {
        message = 'Segera konsultasikan keluhan bapak/ibu ke poliklinik atau faskes terdekat';
      }

      await _showComplaintDialog(message);

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
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
                    children: [
                      // Daftar keluhan checklist
                      ...complaints.map((complaint) {
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

                      // Divider
                      const SizedBox(height: 20),
                      const Divider(thickness: 1),
                      const SizedBox(height: 12),

                      // Label untuk keluhan lainnya
                      const Text(
                        'Keluhan Lainnya:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Input dinamis
                      ...List.generate(_customControllers.length, (index) {
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _customControllers[index],
                                    focusNode: _customFocusNodes[index],
                                    enabled: !_isLoading,
                                    decoration: const InputDecoration(
                                      hintText: 'Tulis keluhan lainnya...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _removeCustomInput(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Tombol tambah input
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _addCustomInput,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Keluhan Lain'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(
                              color: AppColors.secondary,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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