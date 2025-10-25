import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v2.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/presentation/widgets/info_card.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/auth_service.dart';
import 'package:tirtha_app/core/services/education_service.dart';
import 'package:tirtha_app/core/services/quiz_service.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Profile ada di index 3
  final AuthService _authService = AuthService();
  final AuthService _profileService = AuthService();
  final EducationService _educationService = EducationService();
  final QuizService _quizService = QuizService();

  Future<UserModel>? _getUserProfile;
  Future<int>? _educationCount;
  Future<int>? _quizCount;

  // Controllers untuk ganti password
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _getUserProfile = _profileService.getUserProfile();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<int> _getEducationCount() async {
    try {
      final educations = await _educationService.fetchAllEducations();
      return educations.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getQuizCount() async {
    try {
      final quizzes = await _quizService.fetchAllQuizzes();
      return quizzes.length;
    } catch (e) {
      return 0;
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.listEducation);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.listQuiz);
    } else if (index == 3) {
      // Halaman profil (sudah di sini)
    }
  }

  void _showChangePasswordDialog() {
    // Reset controllers dan visibility
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _isOldPasswordVisible = false;
    _isNewPasswordVisible = false;
    _isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Ganti Kata Sandi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Baru
                    TextField(
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Baru',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Konfirmasi Password Baru
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Kata Sandi Baru',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: () {
                        _handleChangePassword();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Simpan Kata Sandi ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleChangePassword() {
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Kata sandi baru harus diisi', isError: true);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Kata sandi baru minimal 6 karakter', isError: true);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok', isError: true);
      return;
    }

    // TODO: Implementasi API call untuk ganti password
    // Contoh:
    // _authService.changePassword(
    //   oldPassword: _oldPasswordController.text,
    //   newPassword: _newPasswordController.text,
    // ).then((success) {
    //   if (success) {
    //     Navigator.pop(context);
    //     _showSnackBar('Kata sandi berhasil diubah', isError: false);
    //   } else {
    //     _showSnackBar('Kata sandi lama salah', isError: true);
    //   }
    // });

    // Sementara simulasi berhasil
    Navigator.pop(context);
    _showSnackBar('Kata Sandi berhasil diubah', isError: false);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _getUserProfile,
      builder: (context, snapshot) {
        // Selalu gunakan BottomNavV1 untuk halaman profile
        Widget bottomNav = const SizedBox.shrink();

        if (snapshot.hasData) {
          bottomNav = BottomNavV1(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const TopBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _buildProfileHeader(snapshot),
                ),
                const SizedBox(height: 24),
                
                // Dashboard hanya untuk admin
                if (snapshot.hasData && snapshot.data!.role == 'admin') ...[
                  const Center(
                    child: Text(
                      'Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FutureBuilder<int>(
                        future: _getEducationCount(),
                        builder: (context, eduSnapshot) {
                          String count = '0';
                          
                          if (eduSnapshot.connectionState == ConnectionState.waiting) {
                            count = '...';
                          } else if (eduSnapshot.hasError) {
                            count = '0';
                            print('Error education count: ${eduSnapshot.error}');
                          } else if (eduSnapshot.hasData) {
                            count = eduSnapshot.data.toString();
                          }
                          
                          return InfoCard(
                            title: 'EDUKASI',
                            count: count,
                            backgroundColor: AppColors.secondary,
                            onPressed: () {
                              // Langsung ke dashboard (akan pakai BottomNavV2 di page educationDashboard)
                              Navigator.pushNamed(
                                  context, AppRoutes.educationDashboard);
                            },
                          );
                        },
                      ),
                      
                      FutureBuilder<int>(
                        future: _getQuizCount(),
                        builder: (context, quizSnapshot) {
                          String count = '0';
                          
                          if (quizSnapshot.connectionState == ConnectionState.waiting) {
                            count = '...';
                          } else if (quizSnapshot.hasError) {
                            count = '0';
                            print('Error quiz count: ${quizSnapshot.error}');
                          } else if (quizSnapshot.hasData) {
                            count = quizSnapshot.data.toString();
                          }
                          
                          return InfoCard(
                            title: 'KUIS',
                            count: count,
                            backgroundColor: AppColors.tertiary,
                            onPressed: () {
                              // Langsung ke dashboard (akan pakai BottomNavV2 di page quizDashboard)
                              Navigator.pushNamed(
                                  context, AppRoutes.quizDashboard);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Card Informasi Akun
                if (snapshot.hasData) ...[
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(height: 24),
                        
                        // Nomor Telepon
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          iconColor: AppColors.primary,
                          label: 'Nomor Telepon',
                          value: snapshot.data!.phone_number ?? '-',
                        ),
                        const SizedBox(height: 16),
                        
                        // Email
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          iconColor: AppColors.secondary,
                          label: 'Email',
                          value: snapshot.data!.email ?? '-',
                        ),
                        const SizedBox(height: 16),
                        
                        // Password dengan tombol ganti
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lock_outlined,
                                color: AppColors.tertiary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '••••••••',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _showChangePasswordDialog,
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Ganti'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Card "Tentang Kami"
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tentang Kami',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'V 1.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Keluar
                ElevatedButton(
                  onPressed: () {
                    _authService.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.preview,
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'KELUAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: bottomNav,
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(AsyncSnapshot<UserModel> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Gagal memuat data: ${snapshot.error}',
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else if (snapshot.hasData) {
      final user = snapshot.data!;
      return Column(
        children: [
          const Text(
            'PROFIL SAYA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/default-avatar.png'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user.role ?? "Role tidak tersedia",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      return const Center(
        child: Text(
          'Tidak ada data profil.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}