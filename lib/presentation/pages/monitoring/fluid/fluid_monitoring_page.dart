import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/fluid_service.dart';
import 'package:tirtha_app/data/models/fluid_model.dart';
import 'package:intl/intl.dart';

class FluidMonitoringPage extends StatefulWidget {
  const FluidMonitoringPage({Key? key}) : super(key: key);

  @override
  State<FluidMonitoringPage> createState() => _FluidMonitoringPageState();
}

class _FluidMonitoringPageState extends State<FluidMonitoringPage> {
  final FluidService _fluidService = FluidService();
  List<FluidBalanceLogResponseDTO> _fluidData = [];
  bool _isLoading = false;
  String _selectedFilter = 'today'; // 'today' or 'week'
  bool _hasShownInitialWarning = false;

  @override
  void initState() {
    super.initState();
    _loadFluidData();
  }

  Future<void> _loadFluidData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _fluidService.getFluids();
      if (mounted) {
        setState(() {
          _fluidData = data;
          _isLoading = false;
        });
        
        // Show warning if balance >= 500 for today and not shown yet
        if (!_hasShownInitialWarning && _selectedFilter == 'today') {
          _checkAndShowWarning();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkAndShowWarning() {
    final filteredData = _getFilteredData();
    if (filteredData.isNotEmpty) {
      final balance = _calculateBalance(filteredData);
      if (balance >= 500) {
        _hasShownInitialWarning = true;
        // Show warning after a short delay to ensure UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBalanceWarningDialog(balance);
        });
      }
    }
  }

  List<FluidBalanceLogResponseDTO> _getFilteredData() {
    if (_fluidData.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedFilter == 'today') {
      // Filter for today only
      return _fluidData.where((log) {
        final logDate = DateTime.parse(log.logDate);
        final logDay = DateTime(logDate.year, logDate.month, logDate.day);
        return logDay.isAtSameMomentAs(today);
      }).toList();
    } else {
      // Filter for last 7 days
      final sevenDaysAgo = today.subtract(const Duration(days: 6));
      return _fluidData.where((log) {
        final logDate = DateTime.parse(log.logDate);
        final logDay = DateTime(logDate.year, logDate.month, logDate.day);
        return logDay.isAfter(sevenDaysAgo.subtract(const Duration(days: 1))) &&
               logDay.isBefore(today.add(const Duration(days: 1)));
      }).toList()..sort((a, b) => a.logDate.compareTo(b.logDate));
    }
  }

  // Update untuk method _showInfoDialog() di FluidMonitoringPage
// Ganti method ini di dalam class _FluidMonitoringPageState

void _showInfoDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Keterangan Satuan Cairan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Gambar gelas belimbing
              Image.asset(
                'assets/gelas_blimbing.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.local_drink,
                    size: 80,
                    color: Colors.teal[300],
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: const Text(
                  '250 cc = 1 gelas belimbing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilihan Cairan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cairan Masuk',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildOptionItem('250 cc'),
                        _buildOptionItem('500 cc'),
                        _buildOptionItem('750 cc'),
                        _buildOptionItem('1000 cc'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cairan Keluar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildOptionItem('0 cc'),
                        _buildOptionItem('50 cc'),
                        _buildOptionItem('250 cc'),
                        _buildOptionItem('500 cc'),
                        _buildOptionItem('750 cc'),
                        _buildOptionItem('1000 cc'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
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
      );
    },
  );
}

  void _showBalanceWarningDialog(int balance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 64,
          ),
          title: const Text(
            'Peringatan Rata-rata Cairan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  'Rata-rata cairan Anda saat ini adalah $balance cc. Harap segera konsultasikan dengan dokter atau perawat untuk pemantauan lebih lanjut.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rata-rata cairan lebih dari 500 cc memerlukan perhatian medis.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    final balance = _calculateBalance(filteredData);
    final hasWarning = _selectedFilter == 'today' && balance >= 500;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.tertiary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pemantauan Cairan',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.tertiary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFluidData,
              color: AppColors.tertiary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rekap Pemantauan Cairan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: _showInfoDialog,
                          icon: const Icon(
                            Icons.help_outline,
                            color: AppColors.tertiary,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'today',
                              child: Text(
                                'Per Hari',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'week',
                              child: Text(
                                '7 Hari Terakhir',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                _selectedFilter = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Chart Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Grafik Pemantauan Cairan (cc)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegend('Cairan Masuk', Colors.blue),
                              const SizedBox(width: 24),
                              _buildLegend('Cairan Keluar', Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: filteredData.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.water_drop_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Belum ada data pemantauan cairan',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: _calculateMaxY(filteredData),
                                      minY: 0,
                                      groupsSpace: 12,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            String label = rodIndex == 0 ? 'Masuk' : 'Keluar';
                                            return BarTooltipItem(
                                              '$label\n${rod.toY.toInt()} cc',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                                                final log = filteredData[value.toInt()];
                                                final date = DateTime.parse(log.logDate);
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    DateFormat('dd/MM').format(date),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                            reservedSize: 30,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${value.toInt()}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey[300]!),
                                          left: BorderSide(color: Colors.grey[300]!),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 500,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey[200]!,
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      barGroups: filteredData.asMap().entries.map((entry) {
                                        return BarChartGroupData(
                                          x: entry.key,
                                          barRods: [
                                            BarChartRodData(
                                              toY: entry.value.intakeCC.toDouble(),
                                              color: Colors.blue,
                                              width: 12,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(4),
                                              ),
                                            ),
                                            BarChartRodData(
                                              toY: entry.value.outputCC.toDouble(),
                                              color: Colors.orange,
                                              width: 12,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(4),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Summary Cards
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Cairan Masuk',
                                _calculateTotalIntake(filteredData),
                                Colors.blue,
                                Icons.water_drop,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Cairan Keluar',
                                _calculateTotalOutput(filteredData),
                                Colors.orange,
                                Icons.water_drop_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBalanceCard(
                          'Rata-rata Cairan',
                          balance,
                          hasWarning: hasWarning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (context.mounted) {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.createFluidMonitoring,
            );
            
            // Reload data if result is true (data was saved)
            if (result == true) {
              _hasShownInitialWarning = false; // Reset flag to show warning again if needed
              _loadFluidData();
            }
          }
        },
        backgroundColor: AppColors.tertiary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value cc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, int value, {bool hasWarning = false}) {
    final isPositive = value >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    
    return GestureDetector(
      onTap: hasWarning ? () => _showBalanceWarningDialog(value) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasWarning ? Colors.orange.withOpacity(0.5) : color.withOpacity(0.3),
            width: hasWarning ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (hasWarning) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}$value cc',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isPositive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Defisit',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      if (isPositive && value > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Surplus',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (hasWarning)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 12,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ketuk untuk melihat peringatan',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalIntake(List<FluidBalanceLogResponseDTO> data) {
    return data.fold(0, (sum, item) => sum + item.intakeCC);
  }

  int _calculateTotalOutput(List<FluidBalanceLogResponseDTO> data) {
    return data.fold(0, (sum, item) => sum + item.outputCC);
  }

  int _calculateBalance(List<FluidBalanceLogResponseDTO> data) {
    return data.fold(0, (sum, item) => sum + item.balanceCC);
  }

  double _calculateMaxY(List<FluidBalanceLogResponseDTO> data) {
    if (data.isEmpty) return 3000;
    
    int maxValue = 0;
    for (var item in data) {
      if (item.intakeCC > maxValue) maxValue = item.intakeCC;
      if (item.outputCC > maxValue) maxValue = item.outputCC;
    }
    
    // Round up to nearest 500
    return ((maxValue / 500).ceil() * 500).toDouble() + 500;
  }
}