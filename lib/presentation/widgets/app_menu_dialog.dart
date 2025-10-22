import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/auth_service.dart';
import 'package:tirtha_app/data/models/user_model.dart';

class AppMenuDialog extends StatefulWidget {
  const AppMenuDialog({super.key});

  @override
  State<AppMenuDialog> createState() => _AppMenuDialogState();
}

class _AppMenuDialogState extends State<AppMenuDialog> {
  final AuthService _authService = AuthService();
  late Future<UserModel> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _authService.getUserProfile();
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String route,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.only(top: kToolbarHeight, left: 16),
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
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder<UserModel>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat profil: ${snapshot.error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            final role = user.role ?? 'user';

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/doctor.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.id.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            role,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 30),

                if (role == 'admin')
                  _buildMenuItem(
                    context,
                    'Dashboard Edukasi',
                    AppRoutes.educationDashboard,
                    AppColors.secondary,
                  ),

                if (role == 'admin')
                  _buildMenuItem(
                    context,
                    'Dashboard Kuis',
                    AppRoutes.quizDashboard,
                    AppColors.primary,
                  ),

                if (role == 'admin')
                  const Divider(height: 30),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _authService.logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.preview,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'KELUAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Data tidak tersedia'));
          }
        },
      ),
    );
  }
}
