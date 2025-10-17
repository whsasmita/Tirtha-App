import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/app_text_field.dart';
import 'package:tirtha_app/presentation/widgets/app_bar_back.dart';
import 'package:tirtha_app/core/services/quiz_service.dart';

class UpsertQuizPage extends StatefulWidget {
  final int? quizId; 

  const UpsertQuizPage({Key? key, this.quizId}) : super(key: key);

  @override
  _UpsertQuizPageState createState() => _UpsertQuizPageState();
}

class _UpsertQuizPageState extends State<UpsertQuizPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final QuizService _quizService = QuizService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.quizId != null) {
      _loadQuizData();
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

  Future<void> _loadQuizData() async {
    try {
      final quiz = await _quizService.fetchQuizById(widget.quizId!);
      _nameController.text = quiz.name;
      _urlController.text = quiz.url;
    } catch (e) {
      _showError('Gagal memuat data kuis: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _handleUpsertQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_nameController.text.trim().isEmpty || _urlController.text.trim().isEmpty) {
      _showError('Judul dan Link tidak boleh kosong.');
      return;
    }

    try {
      final name = _nameController.text.trim();
      final url = _urlController.text.trim();
      
      final isUpdating = widget.quizId != null;
      String successMessage;
      
      if (isUpdating) {
        await _quizService.updateQuiz(widget.quizId!, name, url);
        successMessage = 'Quiz berhasil diperbarui!';
      } else {
        await _quizService.saveQuiz(name, url); 
        successMessage = 'Quiz berhasil dibuat!';
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

  void _handleReset() {
    _nameController.clear();
    _urlController.clear();
    setState(() {
      _errorMessage = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quizId != null;
    final title = isEditing ? 'Edit Kuis' : 'Buat Kuis';
    final buttonText = isEditing ? 'SIMPAN PERUBAHAN' : 'BUAT';

    if (_isInitialLoading) {
      return const Scaffold(
        appBar: AppBarBack(title: 'Memuat Data...', backgroundColor: AppColors.tertiary),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarBack(
        title: title,
        backgroundColor: AppColors.tertiary,
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
              hintText: 'Masukkan judul quiz',
              controller: _nameController,
            ),
            const SizedBox(height: 24),
            const Text(
              'Link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              hintText: 'Masukkan link quiz',
              controller: _urlController,
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
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
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
                    onPressed: _isLoading ? null : _handleUpsertQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLoading ? 'Loading...' : buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}