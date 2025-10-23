import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/widgets/app_bar_back.dart';
import 'package:tirtha_app/core/services/education_service.dart';

class UpsertEducationPage extends StatefulWidget {
  final int? educationId; 

  const UpsertEducationPage({Key? key, this.educationId}) : super(key: key);

  @override
  _UpsertEducationPageState createState() => _UpsertEducationPageState();
}

class _UpsertEducationPageState extends State<UpsertEducationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();
  final EducationService _educationService = EducationService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.educationId != null) {
      _loadEducationData();
    } else {
      _isInitialLoading = false; 
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _loadEducationData() async {
    try {
      final education = await _educationService.fetchEducationById(widget.educationId!);
      _nameController.text = education.name;
      _urlController.text = education.url;
      _thumbnailController.text = education.thumbnail;
    } catch (e) {
      _showError('Gagal memuat data edukasi: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text(
                'Ya',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUpsertEducation() async {
    if (_nameController.text.trim().isEmpty || _urlController.text.trim().isEmpty) {
      _showError('Judul dan Link tidak boleh kosong.');
      return;
    }

    final isUpdating = widget.educationId != null;
    final confirmMessage = isUpdating 
        ? 'Apakah Anda yakin ingin menyimpan perubahan?'
        : 'Apakah Anda yakin ingin membuat edukasi ini?';

    await _showConfirmationDialog(
      title: 'Konfirmasi',
      content: confirmMessage,
      onConfirm: _executeUpsertEducation,
    );
  }

  Future<void> _executeUpsertEducation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final url = _urlController.text.trim();
      final thumbnail = _thumbnailController.text.trim();
      
      final isUpdating = widget.educationId != null;
      String successMessage;
      
      if (isUpdating) {
        await _educationService.updateEducation(widget.educationId!, name, url, thumbnail);
        successMessage = 'Education berhasil diperbarui!';
      } else {
        await _educationService.saveEducation(name, url, thumbnail); 
        successMessage = 'Education berhasil dibuat!';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> _handleReset() async {
    await _showConfirmationDialog(
      title: 'Konfirmasi Reset',
      content: 'Apakah Anda yakin ingin mereset semua field?',
      onConfirm: _executeReset,
    );
  }

  void _executeReset() {
    _nameController.clear();
    _urlController.clear();
    _thumbnailController.clear();
    setState(() {
      _errorMessage = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.educationId != null;
    final title = isEditing ? 'Edit Edukasi' : 'Buat Edukasi';
    final buttonText = isEditing ? 'SIMPAN PERUBAHAN' : 'BUAT';

    if (_isInitialLoading) {
      return const Scaffold(
        appBar: AppBarBack(title: 'Memuat Data...', backgroundColor: AppColors.secondary),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarBack(
        title: title,
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Judul',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan judul edukasi',
              controller: _nameController,
            ),
            const SizedBox(height: 24),
            const Text(
              'Link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan link edukasi',
              controller: _urlController,
            ),
            const SizedBox(height: 24),
            const Text(
              'Thumbnail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan link thumbnail',
              controller: _thumbnailController,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Unggah Cover (Fungsionalitas dinonaktifkan)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Unggah cover (Tidak aktif)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: null,
                      child: const Text(
                        'Unggah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Extra space untuk bottom navbar
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'RESET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpsertEducation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}