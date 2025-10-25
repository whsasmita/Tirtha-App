import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/bottom_nav_v1.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';
import 'package:tirtha_app/routes/app_routes.dart';
import 'package:tirtha_app/core/services/drug_schedule_service.dart';
import 'package:tirtha_app/core/services/control_schedule_service.dart';
import 'package:tirtha_app/core/services/hemodialysis_schedule_service.dart';
import 'package:tirtha_app/data/models/drug_schedule_model.dart';
import 'package:tirtha_app/data/models/control_schedule_model.dart';
import 'package:tirtha_app/data/models/hemodialysis_schedule_model.dart';

// Combined model untuk display
class ReminderItem {
  final int id;
  final String type; // 'drug', 'control', or 'hemodialysis'
  final String title;
  final String date;
  final String? times;
  final String? dose;
  final bool isActive;
  final dynamic originalData;

  ReminderItem({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.times,
    this.dose,
    required this.isActive,
    this.originalData,
  });
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  int _selectedIndex = 0;
  Set<int> _expandedItems = {};
  
  List<ReminderItem> _allReminders = [];
  List<ReminderItem> _filteredReminders = [];
  bool _isLoading = true;
  
  String? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();

  final DrugScheduleService _drugScheduleService = DrugScheduleService();
  final ControlScheduleService _controlScheduleService = ControlScheduleService();
  final HemodialysisScheduleService _hemodialysisScheduleService = HemodialysisScheduleService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHelpDialog();
    });
    _fetchAllReminders();
  }

  Future<void> _fetchAllReminders() async {
    // Check if the state is mounted before setting state
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    List<ReminderItem> reminders = [];

    try {
      // Fetch schedules with error handling and null checks
      
      // Fetch drug schedules
      try {
        final drugSchedules = await _drugScheduleService.getDrugSchedules();
        for (var drug in drugSchedules.where((s) => s.isActive)) {
          reminders.add(ReminderItem(
            id: drug.id,
            type: 'drug',
            title: drug.drugName,
            date: drug.scheduleDate,
            times: _getScheduleTimes(drug),
            dose: drug.dose,
            isActive: drug.isActive,
            originalData: drug,
          ));
        }
      } catch (e) {
        print('⚠️ Failed to fetch drug schedules: $e');
      }

      // Fetch control schedules
      try {
        final controlSchedules = await _controlScheduleService.getControlSchedules();
        for (var control in controlSchedules.where((s) => s.isActive)) {
          reminders.add(ReminderItem(
            id: control.id,
            type: 'control',
            title: 'Jadwal Kontrol',
            date: control.controlDate,
            isActive: control.isActive,
            originalData: control,
          ));
        }
      } catch (e) {
        print('⚠️ Failed to fetch control schedules: $e');
      }

      // Fetch hemodialysis schedules
      try {
        final hemodialysisSchedules = await _hemodialysisScheduleService.getHemodialysisSchedules();
        for (var hemo in hemodialysisSchedules.where((s) => s.isActive)) {
          reminders.add(ReminderItem(
            id: hemo.id,
            type: 'hemodialysis',
            title: 'Jadwal Hemodialisis',
            date: hemo.scheduleDate,
            isActive: hemo.isActive,
            originalData: hemo,
          ));
        }
      } catch (e) {
        print('⚠️ Failed to fetch hemodialysis schedules: $e');
      }

      // Sort by date (newest first)
      reminders.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _allReminders = reminders;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Unexpected error in _fetchAllReminders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    List<ReminderItem> filtered = _allReminders;
    
    if (_selectedFilter != null) {
      if (_selectedFilter == 'minum_obat') {
        filtered = filtered.where((r) => r.type == 'drug').toList();
      } else if (_selectedFilter == 'kontrol') {
        filtered = filtered.where((r) => r.type == 'control').toList();
      } else if (_selectedFilter == 'hemodialisis') {
        filtered = filtered.where((r) => r.type == 'hemodialysis').toList();
      }
    }
    
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((reminder) {
        return reminder.title.toLowerCase().contains(searchQuery) ||
              (reminder.dose?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    }
    
    setState(() {
      _filteredReminders = filtered;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Pengingat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildFilterOption(
                title: 'Semua Pengingat',
                icon: Icons.all_inclusive,
                value: null,
                currentValue: _selectedFilter,
              ),
              
              const Divider(height: 24),
              
              _buildFilterOption(
                title: 'Jadwal Minum Obat',
                icon: Icons.medication,
                value: 'minum_obat',
                currentValue: _selectedFilter,
              ),
              
              const Divider(height: 24),
              
              _buildFilterOption(
                title: 'Jadwal Kontrol',
                icon: Icons.local_hospital,
                value: 'kontrol',
                currentValue: _selectedFilter,
              ),
              
              const Divider(height: 24),
              
              _buildFilterOption(
                title: 'Jadwal Hemodialisis',
                icon: Icons.water_drop,
                value: 'hemodialisis',
                currentValue: _selectedFilter,
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = null;
                        });
                        _applyFilter();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required IconData icon,
    required String? value,
    required String? currentValue,
  }) {
    final isSelected = value == currentValue;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilter();
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.tertiary.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.tertiary : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.tertiary : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.tertiary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.listEducation);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedItems.contains(index)) {
        _expandedItems.remove(index);
      } else {
        _expandedItems.add(index);
      }
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Atur pengingat harian Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. untuk minum obat', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('2. jadwal kontrol', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 8),
                    Text('3. jadwal hemodialisis', style: TextStyle(fontSize: 15)),
                    // SizedBox(height: 8),
                    // Text('4. Pemantauan cairan.', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dengan pengingat yang teratur, Anda bisa lebih disiplin, terhindar dari komplikasi, dan merasa lebih tenang menjalani terapi.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editReminder(int index) async {
    final reminder = _filteredReminders[index];
    
    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.createReminder,
      arguments: reminder.originalData,
    );
    
    if (result == true && mounted) {
      _fetchAllReminders();
    }
  }

  void _deleteReminder(int index) {
    final reminder = _filteredReminders[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengingat "${reminder.title}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final confirmationContext = context;
              Navigator.pop(confirmationContext); // Close confirmation dialog

              // 1. Simpan Future untuk dialog loading
              BuildContext? loadingDialogContext;

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) { // Gunakan ctx sebagai konteks dialog loading
                  loadingDialogContext = ctx; // Simpan konteks dialog loading
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );

              // Tambahkan delay kecil untuk memastikan dialog loading benar-benar ada
              // di tree sebelum operasi delete berjalan. Ini adalah praktik aman (safe practice).
              await Future.delayed(const Duration(milliseconds: 50));
              
              try {
                // Delete based on type
                if (reminder.type == 'drug') {
                  await _drugScheduleService.deleteDrugSchedule(reminder.id.toString());
                } else if (reminder.type == 'control') {
                  await _controlScheduleService.deleteControlSchedule(reminder.id);
                } else if (reminder.type == 'hemodialysis') {
                  await _hemodialysisScheduleService.deleteHemodialysisSchedule(reminder.id);
                }

                // Close loading dialog first
                // Menggunakan loadingDialogContext yang telah disimpan
                if (mounted && loadingDialogContext != null) {
                  // HANYA pop jika konteks masih 'mounted' dan valid
                  if (Navigator.canPop(loadingDialogContext!)) {
                    Navigator.of(loadingDialogContext!).pop(); // Hide loading
                  }
                }

                // Refresh list
                await _fetchAllReminders();

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengingat "${reminder.title}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error deleting reminder: $e');
                
                // Close loading dialog
                // Menggunakan loadingDialogContext yang telah disimpan
                if (mounted && loadingDialogContext != null) {
                  // HANYA pop jika konteks masih 'mounted' dan valid
                  if (Navigator.canPop(loadingDialogContext!)) {
                    Navigator.of(loadingDialogContext!).pop(); // Hide loading
                  }
                }

                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus pengingat: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
  
  String _getScheduleTimes(DrugScheduleResponseDTO schedule) {
    final times = <String>[];
    if (schedule.at06) times.add('06:00');
    if (schedule.at12) times.add('12:00');
    if (schedule.at18) times.add('18:00');

    // Menggunakan join(', ') untuk menggabungkan elemen list menjadi string
    // dengan koma dan spasi sebagai pemisah.
    return times.isEmpty ? 'Tidak ada jadwal' : times.join(', ');
}

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      print('Date format error: $e');
    }
    return date;
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case 'drug':
        return Icons.medication;
      case 'control':
        return Icons.local_hospital;
      case 'hemodialysis':
        return Icons.water_drop;
      default:
        return Icons.notifications;
    }
  }

  Color _getReminderColor(String type) {
    switch (type) {
      case 'drug':
        return AppColors.tertiary;
      case 'control':
        return Colors.blue;
      case 'hemodialysis':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getReminderLabel(String type) {
    switch (type) {
      case 'drug':
        return 'Minum Obat';
      case 'control':
        return 'Kontrol';
      case 'hemodialysis':
        return 'Hemodialisis';
      default:
        return 'Pengingat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar(),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'PENGINGAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white),
                      onPressed: _showHelpDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Cari pengingat disini',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                onChanged: (value) => _applyFilter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _selectedFilter != null 
                            ? AppColors.tertiary 
                            : AppColors.tertiary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onPressed: _showFilterDialog,
                          ),
                          if (_selectedFilter != null)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter indicator
          if (_selectedFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      _selectedFilter == 'minum_obat' ? 'Minum Obat' :
                      _selectedFilter == 'kontrol' ? 'Kontrol' : 'Hemodialisis',
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedFilter = null;
                      });
                      _applyFilter();
                    },
                  ),
                ],
              ),
            ),

          // Reminder List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAllReminders,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReminders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter != null
                                    ? 'Tidak ada pengingat untuk kategori ini'
                                    : 'Belum ada jadwal pengingat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap tombol + untuk membuat pengingat baru',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredReminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _filteredReminders[index];
                            final isExpanded = _expandedItems.contains(index);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => _toggleExpand(index),
                                    borderRadius: BorderRadius.circular(15),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: _getReminderColor(reminder.type).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              _getReminderIcon(reminder.type),
                                              color: _getReminderColor(reminder.type),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${_getReminderLabel(reminder.type)}: ${reminder.title}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  reminder.times != null 
                                                      ? '${_formatDate(reminder.date)} | ${reminder.times}'
                                                      : _formatDate(reminder.date),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded) ...[
                                    const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (reminder.dose != null) ...[
                                            Text(
                                              'Dosis: ${reminder.dose}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          if (reminder.times != null) ...[
                                            Text(
                                              'Jam: ${reminder.times}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          Text(
                                            'Status: ${reminder.isActive ? 'Aktif' : 'Tidak Aktif'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: reminder.isActive 
                                                  ? Colors.green.shade700 
                                                  : Colors.red.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => _editReminder(index),
                                                icon: const Icon(Icons.edit_outlined, size: 18),
                                                label: const Text('Edit'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppColors.secondary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton.icon(
                                                onPressed: () => _deleteReminder(index),
                                                icon: const Icon(Icons.delete_outline, size: 18),
                                                label: const Text('Hapus'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.createReminder);
          
          if (result == true && mounted) {
            _fetchAllReminders();
          }
        },
        backgroundColor: AppColors.tertiary,
        child: const Icon(Icons.alarm_add, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}