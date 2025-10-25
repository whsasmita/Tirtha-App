import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/app_menu_dialog.dart';
import 'package:tirtha_app/core/services/auth_service.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  final AuthService _authService = AuthService();
  UserModel? _userProfile;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _authService.getUserProfile();
      setState(() {
        _userProfile = user;
        _userRole = user.role ?? 'user';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userProfile = null;
        _userRole = 'user';
        _isLoading = false;
      });
    }
  }

  void _showMenuDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return const AppMenuDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Align(
          alignment: Alignment.topLeft,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Helper untuk mendapatkan ImageProvider berdasarkan data profil
  ImageProvider _getProfileImage() {
    final profilePictureUrl = _userProfile?.profilePicture;
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      return NetworkImage(profilePictureUrl);
    }
    return const AssetImage('assets/default-avatar.png'); 
  }

  // Helper untuk mendapatkan nama pengguna
  String _getUserName() {
    return _userProfile?.name ?? 'Pengguna';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final isAdmin = _userRole == 'admin';
    final userName = _getUserName();
    final profileImage = _getProfileImage();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      
      // =======================================================
      // Bagian LEADING: Ikon Menu untuk Admin / Logo Aplikasi untuk User
      // =======================================================
      leading: isAdmin
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () {
                _showMenuDialog(context);
              },
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/logo_tirtha_app.png',
                fit: BoxFit.contain,
              ),
            ),
      
      // Menggunakan titleTextStyle untuk menyesuaikan gaya title saat tidak null
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis,
      ),
      
      // =======================================================
      // Bagian ACTIONS: Foto Profil (untuk semua user)
      // =======================================================
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              // Navigate ke profile page
              // Navigator.pushNamed(context, AppRoutes.profile);
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              backgroundImage: profileImage,
              onBackgroundImageError: (exception, stackTrace) {
                // Biarkan default avatar muncul atau kosongkan jika error
              },
              child: profileImage is AssetImage
                  ? Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}