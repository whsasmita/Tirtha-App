import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/hemodialysis_service.dart';
import 'package:tirtha_app/data/models/hemodialysis_model.dart';

class HemodialysisMonitoringPage extends StatefulWidget {
  const HemodialysisMonitoringPage({Key? key}) : super(key: key);

  @override
  State<HemodialysisMonitoringPage> createState() =>
      _HemodialysisMonitoringPageState();
}

class _HemodialysisMonitoringPageState
    extends State<HemodialysisMonitoringPage> {
  final HemodialysisMonitoringService _service =
      HemodialysisMonitoringService();
  List<HemodialysisMonitoringItem> _monitorings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getHemodialysisMonitoring();

      data.sort((a, b) {
        final dateA = DateTime.parse(a.monitoringDate);
        final dateB = DateTime.parse(b.monitoringDate);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _monitorings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(String apiDate) {
    try {
      final parts = apiDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return apiDate;
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Rekap Pantauan Selama Hemodialisa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.createHemodialysisMonitoring,
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppColors.tertiary,
        icon: const Icon(Icons.add, color: AppColors.textSecondary),
        label: const Text(
          'Tambah Data',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_monitorings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data pemantauan hemodialisa.\nTambahkan data pertama Anda!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildModernTable(_monitorings),
      ),
    );
  }

  Widget _buildModernTable(List<HemodialysisMonitoringItem> data) {
    const double colWidth = 110.0;
    const double dateColWidth = 120.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row 1 - Main Categories
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.secondary.withOpacity(0.85),
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModernHeaderCell(
                    'Tanggal',
                    width: dateColWidth,
                    height: 60,
                    rowspan: true,
                    icon: Icons.calendar_today,
                  ),
                  _buildModernHeaderCell(
                    'Tekanan Darah',
                    width: colWidth * 2,
                    height: 58, // Dari 30 → 50
                    // icon: Icons.favorite,
                    subtitle: 'MMHG',
                  ),
                  _buildModernHeaderCell(
                    'Berat Badan',
                    width: colWidth * 2,
                    height: 58, // Dari 30 → 50
                    isLast: true,
                    // icon: Icons.monitor_weight,
                    subtitle: 'KG',
                  ),
                ],
              ),
            ),
            // Header Row 2 - Sub Categories
            Container(
              color: AppColors.secondary.withOpacity(0.15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: dateColWidth),
                  _buildSubHeaderCell('Sebelum HD', width: colWidth),
                  _buildSubHeaderCell('Setelah HD', width: colWidth),
                  _buildSubHeaderCell('Sebelum HD', width: colWidth),
                  _buildSubHeaderCell(
                    'Setelah HD',
                    width: colWidth,
                    isLast: true,
                  ),
                ],
              ),
            ),
            // Data rows with alternating colors
            ...data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildModernDataRow(item, index);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeaderCell(
    String text, {
    required double width,
    required double height,
    bool rowspan = false,
    bool isLast = false,
    IconData? icon,
    String? subtitle,
  }) {
    return Container(
      width: width,
      height: rowspan ? 90 : height,
      decoration: BoxDecoration(
        border: Border(
          right:
              isLast
                  ? BorderSide.none
                  : BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ), // Kurangi padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // TAMBAHKAN INI
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16), // Dari 20 → 16
            const SizedBox(height: 2), // Dari 4 → 2
          ],
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15, // Dari 13 → 11
              color: Colors.white,
              height: 1.1, // Dari 1.2 → 1.1
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1), // Dari 2 → 1
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15, // Dari 10 → 9
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubHeaderCell(
    String text, {
    required double width,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          right:
              isLast
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey[300]!, width: 1),
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildModernDataRow(HemodialysisMonitoringItem item, int index) {
    const double colWidth = 110.0;
    const double dateColWidth = 120.0;
    final isEven = index % 2 == 0;

    return Container(
      color: isEven ? Colors.white : Colors.grey[50],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModernDataCell(
            _formatDate(item.monitoringDate),
            width: dateColWidth,
            isDate: true,
          ),
          _buildModernDataCell(item.bpBefore, width: colWidth),
          _buildModernDataCell(item.bpAfter, width: colWidth),
          _buildModernDataCell('${item.weightBefore}', width: colWidth),
          _buildModernDataCell(
            '${item.weightAfter}',
            width: colWidth,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernDataCell(
    String text, {
    required double width,
    bool isLast = false,
    bool isDate = false,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right:
              isLast
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey[200]!, width: 1),
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isDate ? 12 : 13,
            fontWeight: isDate ? FontWeight.w600 : FontWeight.w500,
            color: isDate ? AppColors.secondary : Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
