// File: upsert_education_page.dart

import 'dart:io'; // Digunakan untuk Image.file
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/widgets/app_bar_back.dart';
import 'package:tirtha_app/core/services/education_service.dart';

// Asumsi:
// - EducationService, AppTextField, AppBarBack sudah didefinisikan di tempat lain.
// - EducationModel memiliki properti 'thumbnail' (URL string) untuk ditampilkan saat edit.

class UpsertEducationPage extends StatefulWidget {
  final int? educationId; 

  const UpsertEducationPage({Key? key, this.educationId}) : super(key: key);

  @override
  _UpsertEducationPageState createState() => _UpsertEducationPageState();
}

class _UpsertEducationPageState extends State<UpsertEducationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final EducationService _educationService = EducationService();

  XFile? _selectedImage; 
  String? _existingThumbnailUrl; // Untuk menampilkan gambar yang sudah ada saat mode edit

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
    super.dispose();
  }

  Future<void> _loadEducationData() async {
    try {
      final education = await _educationService.fetchEducationById(widget.educationId!);
      _nameController.text = education.name;
      _urlController.text = education.url;
      // Asumsi EducationModel memiliki field thumbnail (string URL)
      _existingThumbnailUrl = education.thumbnail; 
    } catch (e) {
      _showError('Gagal memuat data edukasi: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  // Metode untuk memilih gambar
  Future<void> _pickImage() async {
    if (_isLoading) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _errorMessage = null; 
        });
      }
    } catch (e) {
      // Menangani izin atau error lain saat memilih gambar
      _showError('Gagal memilih gambar. Pastikan izin galeri diizinkan: $e');
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
    
    // Validasi Gambar hanya untuk mode Create jika belum ada thumbnail yang tersimpan
    if (!isUpdating && _selectedImage == null) {
      _showError('Thumbnail gambar wajib diisi saat membuat edukasi baru.');
      return;
    }

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
      
      final isUpdating = widget.educationId != null;
      String successMessage;
      
      if (isUpdating) {
        // Mode Edit: Kirim file jika ada yang dipilih, jika tidak, kirim null
        await _educationService.updateEducation(widget.educationId!, name, url, _selectedImage); 
        successMessage = 'Education berhasil diperbarui!';
      } else {
        // Mode Create: Wajib ada file (sudah divalidasi di _handleUpsertEducation)
        await _educationService.saveEducation(name, url, _selectedImage!); 
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
    setState(() {
      _selectedImage = null; 
      _existingThumbnailUrl = null;
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
            // Judul
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

            // Link
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
            
            // Fungsionalitas Upload Gambar/Thumbnail (AKTIF)
            const Text(
              'Unggah Cover/Thumbnail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  // Validasi tampilan error jika file wajib tapi belum dipilih
                  color: !isEditing && _selectedImage == null && _errorMessage != null 
                        ? Colors.red
                        : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _selectedImage?.name ?? 'Pilih Gambar...',
                        style: TextStyle(
                          color: _selectedImage == null ? Colors.grey : AppColors.textPrimary,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey.shade400 : AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : _pickImage, // AKTIF
                      child: const Text(
                        'Pilih File',
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
            
            // Pratinjau Gambar
            if (_selectedImage != null) 
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 150,
                  fit: BoxFit.contain,
                ),
              )
            else if (_existingThumbnailUrl != null && _existingThumbnailUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thumbnail Tersimpan:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Image.network(
                      _existingThumbnailUrl!,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('Gagal memuat thumbnail yang tersimpan.'),
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