import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/app_menu_dialog.dart';
import 'package:tirtha_app/core/services/auth_service.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  final AuthService _authService = AuthService();
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = await _authService.getUserProfile();
      setState(() {
        _userRole = user.role ?? 'user';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
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
                'assets/logo_tirtha_app.png', // Ganti dengan path logo aplikasi Anda
                fit: BoxFit.contain,
              ),
            ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              // Navigate ke profile page
              // Navigator.pushNamed(context, AppRoutes.profile);
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/default-avatar.png'), // Ganti dengan foto profil user
              backgroundColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}