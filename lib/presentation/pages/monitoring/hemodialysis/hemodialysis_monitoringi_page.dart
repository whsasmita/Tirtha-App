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

      // --- PERBAIKAN: SORTING DATA BERDASARKAN TANGGAL ---
      data.sort((a, b) {
        // Membandingkan tanggal, dari terbaru ke terlama (descending)
        // Mengubah string tanggal YYYY-MM-DD menjadi DateTime untuk perbandingan
        final dateA = DateTime.parse(a.monitoringDate);
        final dateB = DateTime.parse(b.monitoringDate);
        return dateB.compareTo(dateA); // b compareTo a = descending
      });
      // -----------------------------------------------------

      setState(() {
        _monitorings = data;
        _isLoading = false;
      });
    } catch (e) {
      // ... (penanganan error tetap sama)
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(String apiDate) {
    try {
      // Format dari API: "2025-10-24" (YYYY-MM-DD)
      // Ubah ke: "24-10-2025" (DD-MM-YYYY)
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: _loadData,
          ),
        ],
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
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildCustomTable(_monitorings),
    );
  }

  Widget _buildCustomTable(List<HemodialysisMonitoringItem> data) {
    const double colWidth = 95.0;
    const double dateColWidth = 110.0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row 1
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderCell(
                  'Tanggal',
                  width: dateColWidth,
                  height: 70,
                  rowspan: true,
                ),
                _buildHeaderCell(
                  'Tekanan Darah (MMHG)',
                  width: colWidth * 2,
                  height: 35,
                ),
                _buildHeaderCell(
                  'Berat Badan (KG)',
                  width: colWidth * 2,
                  height: 35,
                  isLast: true,
                ),
              ],
            ),
            // Header Row 2
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: dateColWidth,
                  height: 35,
                  color: AppColors.secondary,
                ),
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
            // Data rows
            ...data.map((item) => _buildDataRow(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    required double width,
    required double height,
    bool rowspan = false,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          right:
              isLast ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
          bottom:
              rowspan ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
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
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.9),
        border: Border(
          right:
              isLast ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataRow(HemodialysisMonitoringItem item) {
    const double colWidth = 95.0;
    const double dateColWidth = 110.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDataCell(_formatDate(item.monitoringDate), width: dateColWidth),
        _buildDataCell(item.bpBefore, width: colWidth),
        _buildDataCell(item.bpAfter, width: colWidth),
        _buildDataCell('${item.weightBefore} Kg', width: colWidth),
        _buildDataCell('${item.weightAfter} Kg', width: colWidth, isLast: true),
      ],
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right:
              isLast ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
