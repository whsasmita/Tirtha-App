import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
        ),
        title: const Text(
          'PEMANTAUAN',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMonitoringCard(
              context: context,
              title: 'Punya Keluhan?',
              imagePath: 'assets/keluhan.png',
              backgroundColor: AppColors.tertiary,
              imageOnLeft: true,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.complaintMonitoring);
              },
            ),
            const SizedBox(height: 16),
            _buildMonitoringCard(
              context: context,
              title: 'Pantau Hemodialisa',
              imagePath: 'assets/hemodialisa.png',
              backgroundColor: AppColors.primary,
              imageOnLeft: false,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.hemodialysisMonitoring);
              },
            ),
            const SizedBox(height: 16),
            _buildMonitoringCard(
              context: context,
              title: 'Pantau Cairan',
              imagePath: 'assets/cairan.png',
              backgroundColor: const Color(0xFF5A5A5A),
              imageOnLeft: true,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.fluidMonitoring);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
    bool imageOnLeft = false,
  }) {
    final imageWidget = Expanded(
      flex: 1,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        height: 120,
      ),
    );

    final contentWidget = Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Pantau Sekarang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: imageOnLeft
              ? [
                  imageWidget,
                  const SizedBox(width: 16),
                  contentWidget,
                ]
              : [
                  contentWidget,
                  const SizedBox(width: 16),
                  imageWidget,
                ],
        ),
      ),
    );
  }
}