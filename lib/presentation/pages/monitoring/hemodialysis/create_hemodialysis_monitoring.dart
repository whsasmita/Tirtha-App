import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/core/services/hemodialysis_service.dart';
import 'package:tirtha_app/data/models/hemodialysis_model.dart';

class CreateHemodialysisMonitoring extends StatefulWidget {
  const CreateHemodialysisMonitoring({Key? key}) : super(key: key);

  @override
  State<CreateHemodialysisMonitoring> createState() =>
      _CreateHemodialysisMonitoringState();
}

class _CreateHemodialysisMonitoringState
    extends State<CreateHemodialysisMonitoring> {
  final _formKey = GlobalKey<FormState>();
  final HemodialysisMonitoringService _service = HemodialysisMonitoringService();

  // Controllers for form fields
  final TextEditingController _tekananSebelumSistolik = TextEditingController();
  final TextEditingController _tekananSebelumDiastolik = TextEditingController();
  final TextEditingController _tekananSetelahSistolik = TextEditingController();
  final TextEditingController _tekananSetelahDiastolik = TextEditingController();
  final TextEditingController _beratSebelum = TextEditingController();
  final TextEditingController _beratSetelah = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _tekananSebelumSistolik.dispose();
    _tekananSebelumDiastolik.dispose();
    _tekananSetelahSistolik.dispose();
    _tekananSetelahDiastolik.dispose();
    _beratSebelum.dispose();
    _beratSetelah.dispose();
    super.dispose();
  }

  void _showResultDialog(
    String title,
    String message, {
    bool isSuccess = true,
  }) {
    IconData icon =
        isSuccess ? Icons.check_circle_outline : Icons.warning_amber_rounded;
    Color iconColor = isSuccess ? Colors.green : Colors.orange;
    Color buttonColor = isSuccess ? AppColors.tertiary : Colors.orange;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          icon: Icon(icon, color: iconColor, size: 48),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup Dialog
                  if (isSuccess) {
                    Navigator.of(context).pop(true); // Kembali dengan hasil sukses
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.refresh, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text('Konfirmasi Reset'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin mereset semua data yang telah diisi?\n\nSemua data akan dikosongkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleReset();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil direset'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitConfirmation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.save_outlined, color: AppColors.secondary),
              const SizedBox(width: 8),
              const Text('Konfirmasi Simpan'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pastikan data yang Anda masukkan sudah benar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('• Tekanan Darah Sebelum: ${_tekananSebelumSistolik.text}/${_tekananSebelumDiastolik.text} mmHg'),
              Text('• Tekanan Darah Sesudah: ${_tekananSetelahSistolik.text}/${_tekananSetelahDiastolik.text} mmHg'),
              Text('• Berat Badan Sebelum: ${_beratSebelum.text} Kg'),
              Text('• Berat Badan Sesudah: ${_beratSetelah.text} Kg'),
              const SizedBox(height: 12),
              const Text('Apakah Anda yakin ingin menyimpan data ini?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _handleReset() {
    setState(() {
      _tekananSebelumSistolik.clear();
      _tekananSebelumDiastolik.clear();
      _tekananSetelahSistolik.clear();
      _tekananSetelahDiastolik.clear();
      _beratSebelum.clear();
      _beratSetelah.clear();
    });
  }

  Future<void> _handleSubmit() async {
    // Show loading
    setState(() => _isLoading = true);

    try {
      // Format blood pressure (sistolik/diastolik)
      final bpBefore = '${_tekananSebelumSistolik.text}/${_tekananSebelumDiastolik.text}';
      final bpAfter = '${_tekananSetelahSistolik.text}/${_tekananSetelahDiastolik.text}';

      // Parse weight to double
      final weightBefore = double.parse(_beratSebelum.text);
      final weightAfter = double.parse(_beratSetelah.text);

      // Create DTO
      final dto = CreateHemodialysisMonitoringDTO(
        bpBefore: bpBefore,
        bpAfter: bpAfter,
        weightBefore: weightBefore,
        weightAfter: weightAfter,
      );

      // Call service
      await _service.createHemodialysisMonitoring(dto);

      // Hide loading
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show success dialog
        _showResultDialog(
          'Berhasil',
          'Data hemodialisa berhasil disimpan',
          isSuccess: true,
        );
      }
    } catch (e) {
      // Hide loading
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show error dialog
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        _showResultDialog(
          'Gagal',
          'Gagal menyimpan data: $errorMessage',
          isSuccess: false,
        );
      }
    }
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
          'PEMANTAUAN SELAMA\nHEMODIALISA',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tekanan Darah
                        const Text(
                          'Tekanan Darah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTekananField(
                          'Sebelum HD',
                          _tekananSebelumSistolik,
                          _tekananSebelumDiastolik,
                        ),
                        const SizedBox(height: 12),
                        _buildTekananField(
                          'Sesudah HD',
                          _tekananSetelahSistolik,
                          _tekananSetelahDiastolik,
                        ),
                        const SizedBox(height: 24),

                        // Berat Badan
                        const Text(
                          'Berat Badan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBeratField('Sebelum HD', _beratSebelum),
                        const SizedBox(height: 12),
                        _buildBeratField('Sesudah HD', _beratSetelah),
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
                          onPressed: _isLoading ? null : _showResetConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A5A5A),
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
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
                          onPressed: _isLoading ? null : _showSubmitConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
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
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTekananField(
    String label,
    TextEditingController sistolikController,
    TextEditingController diastolikController,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: sistolikController,
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'cth : 120',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harus angka';
                }
                return null;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('/', style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: diastolikController,
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'cth : 80',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harus angka';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'mmHg',
            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBeratField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'contoh : 70',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Harus angka';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Kg',
            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}