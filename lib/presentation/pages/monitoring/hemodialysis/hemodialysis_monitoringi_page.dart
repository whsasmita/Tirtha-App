import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/routes/app_routes.dart';

class HemodialysisMonitoringPage extends StatelessWidget {
  const HemodialysisMonitoringPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual data from your state management
    final List<Map<String, dynamic>> hemodialysisData = [
      {
        'tanggal': '12-12-2024',
        'tekananSebelum': '120/80',
        'tekananSetelah': '110/75',
        'beratSebelum': '70',
        'beratSetelah': '65',
      },
      // Add more sample data as needed
    ];

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
      body: SingleChildScrollView(
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
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: hemodialysisData.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Belum ada data hemodialisa',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildCustomTable(hemodialysisData),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createHemodialysisMonitoring);
        },
        backgroundColor: AppColors.tertiary,
        child: const Icon(
          Icons.add,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCustomTable(List<Map<String, dynamic>> data) {
    const double colWidth = 90.0;
    const double dateColWidth = 100.0;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row 1
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tanggal - rowspan 2
              Container(
                width: dateColWidth,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Tanggal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Tekanan Darah - colspan 2
              Container(
                width: colWidth * 2,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Tekanan Darah\n(MMHG)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Berat Badan - colspan 2
              Container(
                width: colWidth * 2,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Berat Badan (KG)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Header Row 2
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Empty space for Tanggal column
              Container(
                width: dateColWidth,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              // Sebelum HD (Tekanan)
              Container(
                width: colWidth,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Sebelum HD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Setelah HD (Tekanan)
              Container(
                width: colWidth,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Setelah HD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Sebelum HD (Berat)
              Container(
                width: colWidth,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Sebelum HD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Setelah HD (Berat)
              Container(
                width: colWidth,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Center(
                  child: Text(
                    'Setelah HD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Data rows
          ...data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataCell(item['tanggal']!, width: dateColWidth),
                _buildDataCell(item['tekananSebelum']!, width: colWidth),
                _buildDataCell(item['tekananSetelah']!, width: colWidth),
                _buildDataCell('${item['beratSebelum']} Kg', width: colWidth),
                _buildDataCell('${item['beratSetelah']} Kg', width: colWidth, isLast: true),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, {required double width, bool isLast = false}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
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