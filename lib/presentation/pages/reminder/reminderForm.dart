import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/core/services/drug_schedule_service.dart';
import 'package:tirtha_app/core/services/control_schedule_service.dart';
import 'package:tirtha_app/core/services/hemodialysis_schedule_service.dart';
import 'package:tirtha_app/core/services/medication_refill_service.dart';
import 'package:tirtha_app/data/models/drug_schedule_model.dart';
import 'package:tirtha_app/data/models/control_schedule_model.dart';
import 'package:tirtha_app/data/models/hemodialysis_schedule_model.dart';
import 'package:tirtha_app/data/models/medication_refill_model.dart';

class ReminderFormPage extends StatefulWidget {
  final dynamic editData;

  const ReminderFormPage({Key? key, this.editData}) : super(key: key);

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String? selectedDate;

  String drugName = '';
  String dose = '1'; // Disimpan sebagai string numerik untuk dosis
  bool at06 = false;
  bool at12 = false;
  bool at18 = false;
  bool isActive = true;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController doseController = TextEditingController(text: '1');

  // Inisialisasi Services
  final DrugScheduleService _drugScheduleService = DrugScheduleService();
  final ControlScheduleService _controlScheduleService =
      ControlScheduleService();
  final HemodialysisScheduleService _hemodialysisScheduleService =
      HemodialysisScheduleService();
  final MedicationRefillService _medicationRefillService =
      MedicationRefillService(); // 🔥 Service Refill

  bool isEditMode = false;
  int? editId;

  // Daftar Kategori yang Diperbarui
  final List<Map<String, dynamic>> categories = [
    {
      'value': 'minum_obat',
      'label': 'Jadwal Minum Obat',
      'icon': Icons.medication,
    },
    {
      'value': 'kontrol',
      'label': 'Jadwal Kontrol',
      'icon': Icons.local_hospital,
    },
    {
      'value': 'hemodialisis',
      'label': 'Jadwal Hemodialisis',
      'icon': Icons.water_drop,
    },
    {
      'value': 'refill',
      'label': 'Jadwal Ambil Obat',
      'icon': Icons.event_repeat,
    }, // 🔥 Kategori Refill
  ];

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {
      isEditMode = true;
      _loadEditData();
    } else {
      DateTime now = DateTime.now();
      // Inisialisasi selectedDate dengan tanggal hari ini dalam format DD-MM-YYYY
      selectedDate =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      dateController.text = selectedDate!;
    }
  }

  // 🔥 Logika Pemuatan Data Edit yang Diperbarui
  void _loadEditData() {
    final data = widget.editData;

    if (data is DrugScheduleResponseDTO) {
      selectedCategory = 'minum_obat';
      editId = data.id;
      drugNameController.text = data.drugName;

      // Extract dose number from string
      final doseMatch = RegExp(r'\d+').firstMatch(data.dose);
      if (doseMatch != null) {
        doseController.text = doseMatch.group(0)!;
      } else {
        doseController.text =
            data.dose.contains(RegExp(r'\d'))
                ? RegExp(r'\d+').firstMatch(data.dose)!.group(0)!
                : '1';
      }

      at06 = data.at06;
      at12 = data.at12;
      at18 = data.at18;
      isActive = data.isActive; // LOAD STATUS

      selectedDate = _convertDateFromAPI(data.scheduleDate);
      dateController.text = selectedDate!;
    } else if (data is ControlScheduleResponseDTO) {
      selectedCategory = 'kontrol';
      editId = data.id;
      isActive = data.isActive; // LOAD STATUS

      selectedDate = _convertDateFromAPI(data.controlDate);
      dateController.text = selectedDate!;
    } else if (data is HemodialysisScheduleResponseDTO) {
      selectedCategory = 'hemodialisis';
      editId = data.id;
      isActive = data.isActive; // LOAD STATUS

      selectedDate = _convertDateFromAPI(data.scheduleDate);
      dateController.text = selectedDate!;
    } else if (data is MedicationRefillResponseDTO) {
      // ✅ PERBAIKAN!
      selectedCategory = 'refill';
      editId = data.id;
      isActive = data.isActive;

      // ✅ data.refillDate adalah String (YYYY-MM-DD)
      selectedDate = _convertDateFromAPI(data.refillDate);
      dateController.text = selectedDate!;
    }
    // Jika data null atau tipe tidak dikenal, biarkan form dalam mode CREATE default.
  }

  // Utility: Convert YYYY-MM-DD (API) to DD-MM-YYYY (Display)
  String _convertDateFromAPI(String apiDate) {
    try {
      final parts = apiDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      return apiDate;
    }
    return apiDate;
  }

  // Utility: Convert DD-MM-YYYY (Display) to YYYY-MM-DD (API)
  String convertDateFormat(String ddMMyyyyDate) {
    try {
      final parts = ddMMyyyyDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      return ddMMyyyyDate;
    }
    return ddMMyyyyDate;
  }

  // Utility: Convert DD-MM-YYYY (Display) to DateTime
  DateTime _convertDisplayDateToDateTime(String ddMMyyyyDate) {
    try {
      final parts = ddMMyyyyDate.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      // Return today's date on error
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    DateTime initialDate =
        selectedDate != null
            ? _convertDisplayDateToDateTime(selectedDate!)
            : today;

    // Pastikan initial date tidak di masa lalu (hanya untuk tampilan picker)
    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today, // Tidak bisa memilih tanggal lalu
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        dateController.text = selectedDate!;
      });
    }
  }

  bool _isTimeSlotAvailable(int hour) {
    if (selectedDate == null) return true;

    final DateTime now = DateTime.now();
    final DateTime selected = _convertDisplayDateToDateTime(selectedDate!);
    final DateTime today = DateTime(now.year, now.month, now.day);

    if (selected.isAfter(today)) {
      return true;
    }

    if (selected.isAtSameMomentAs(today)) {
      final int currentHour = now.hour;
      return currentHour < hour;
    }

    return false;
  }

  void _handleReset() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Reset'),
            content: const Text(
              'Apakah Anda yakin ingin mereset semua isian form?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedCategory = null;
                    drugName = '';
                    dose = '1';
                    at06 = false;
                    at12 = false;
                    at18 = false;
                    isActive = true;
                    drugNameController.clear();
                    doseController.text = '1';

                    DateTime now = DateTime.now();
                    selectedDate =
                        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
                    dateController.text = selectedDate!;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form berhasil di-reset')),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  // 🔥 FUNGSI UTAMA SUBMIT (mengarah ke handler spesifik)
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua isian yang wajib diisi')),
      );
      return;
    }

    if (selectedCategory == 'minum_obat') {
      await _handleDrugScheduleSubmit();
    } else if (selectedCategory == 'kontrol') {
      await _handleControlScheduleSubmit();
    } else if (selectedCategory == 'hemodialisis') {
      await _handleHemodialysisScheduleSubmit();
    } else if (selectedCategory == 'refill') {
      // 🔥 Penambahan
      await _handleMedicationRefillScheduleSubmit();
    }
  }

  // --- HANDLER SPESIFIK ---

  Future<void> _handleDrugScheduleSubmit() async {
    if (!at06 && !at12 && !at18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu jam pengingat obat')),
      );
      return;
    }

    // Validasi waktu terlewat (Drug Schedule specific)
    if (selectedDate != null &&
        _convertDisplayDateToDateTime(selectedDate!).isAtSameMomentAs(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        )) {
      if (at06 && !_isTimeSlotAvailable(6)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Jam 06:00 sudah terlewat untuk hari ini. Silakan batalkan pilihan atau ubah tanggal.',
            ),
          ),
        );
        return;
      }
      if (at12 && !_isTimeSlotAvailable(12)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Jam 12:00 sudah terlewat untuk hari ini. Silakan batalkan pilihan atau ubah tanggal.',
            ),
          ),
        );
        return;
      }
      if (at18 && !_isTimeSlotAvailable(18)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Jam 18:00 sudah terlewat untuk hari ini. Silakan batalkan pilihan atau ubah tanggal.',
            ),
          ),
        );
        return;
      }
    }

    final String apiDateFormat = convertDateFormat(
      selectedDate ?? dateController.text,
    );
    final String formattedDose = doseController.text.trim();

    if (isEditMode && editId != null) {
      // EDIT mode
      final UpdateDrugScheduleDTO updateSchedule = UpdateDrugScheduleDTO(
        drugName: drugNameController.text.trim(),
        dose: formattedDose,
        scheduleDate: apiDateFormat,
        at06: at06,
        at12: at12,
        at18: at18,
        isActive: isActive,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Perubahan'),
              content: Text(
                'Anda akan mengubah jadwal obat "${updateSchedule.drugName}" dengan dosis ${updateSchedule.dose} pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Perbarui'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        await _drugScheduleService.updateDrugSchedule(
          editId.toString(),
          updateSchedule,
        );
        if (!mounted) return;
        Navigator.pop(context); // Close loading

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Pengingat obat ${updateSchedule.drugName} berhasil diubah.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal mengubah pengingat obat: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    } else {
      // CREATE mode
      final CreateDrugScheduleDTO newSchedule = CreateDrugScheduleDTO(
        drugName: drugNameController.text.trim(),
        dose: formattedDose,
        scheduleDate: apiDateFormat,
        at06: at06,
        at12: at12,
        at18: at18,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Pembuatan'),
              content: Text(
                'Anda akan membuat jadwal obat "${newSchedule.drugName}" dengan dosis ${newSchedule.dose} pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Buat'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        final response = await _drugScheduleService.createDrugSchedule(
          newSchedule,
        );
        if (!mounted) return;
        Navigator.pop(context);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Pengingat obat ${response.drugName} berhasil dibuat.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal membuat pengingat obat: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _handleControlScheduleSubmit() async {
    if (selectedDate == null || selectedDate!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tanggal kontrol')));
      return;
    }

    final String apiDateFormat = convertDateFormat(selectedDate!);

    if (isEditMode && editId != null) {
      // EDIT mode
      final UpdateControlScheduleDTO updateSchedule = UpdateControlScheduleDTO(
        controlDate: apiDateFormat,
        isActive: isActive, // KIRIM STATUS
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Perubahan'),
              content: Text(
                'Anda akan mengubah jadwal kontrol pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Perbarui'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        await _controlScheduleService.updateControlSchedule(
          editId!,
          updateSchedule,
        );
        if (!mounted) return;
        Navigator.pop(context);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Jadwal kontrol pada $selectedDate berhasil diubah.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal mengubah jadwal kontrol: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    } else {
      // CREATE mode
      final CreateControlScheduleDTO newSchedule = CreateControlScheduleDTO(
        controlDate: apiDateFormat,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Pembuatan'),
              content: Text(
                'Anda akan membuat jadwal kontrol pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Buat'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        await _controlScheduleService.createControlSchedule(newSchedule);
        if (!mounted) return;
        Navigator.pop(context);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Jadwal kontrol pada $selectedDate berhasil dibuat.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal membuat jadwal kontrol: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _handleHemodialysisScheduleSubmit() async {
    if (selectedDate == null || selectedDate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal hemodialisis')),
      );
      return;
    }

    final String apiDateFormat = convertDateFormat(selectedDate!);

    if (isEditMode && editId != null) {
      // EDIT mode
      final UpdateHemodialysisScheduleDTO updateSchedule =
          UpdateHemodialysisScheduleDTO(
            scheduleDate: apiDateFormat,
            isActive: isActive, // KIRIM STATUS
          );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Perbarui'),
              content: Text(
                'Anda akan mengubah jadwal hemodialisis pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Perbarui'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        await _hemodialysisScheduleService.updateHemodialysisSchedule(
          editId!,
          updateSchedule,
        );
        if (!mounted) return;
        Navigator.pop(context);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Jadwal hemodialisis pada $selectedDate berhasil diubah.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal mengubah jadwal hemodialisis: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    } else {
      // CREATE mode
      final CreateHemodialysisScheduleDTO newSchedule =
          CreateHemodialysisScheduleDTO(scheduleDate: apiDateFormat);

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Pembuatan'),
              content: Text(
                'Anda akan membuat jadwal hemodialisis pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Buat'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        await _hemodialysisScheduleService.createHemodialysisSchedule(
          newSchedule,
        );
        if (!mounted) return;
        Navigator.pop(context);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Jadwal hemodialisis pada $selectedDate berhasil dibuat.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal membuat jadwal hemodialisis: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // 🔥 FUNGSI BARU: Handler Submit Medication Refill
  Future<void> _handleMedicationRefillScheduleSubmit() async {
    if (selectedDate == null || selectedDate!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tanggal ambil obat')));
      return;
    }

    final String apiDateFormat = convertDateFormat(selectedDate!);

    if (isEditMode && editId != null) {
      // --- MODE EDIT ---
      final UpdateMedicationRefillDTO updateSchedule =
          UpdateMedicationRefillDTO(
            refillDate: apiDateFormat,
            isActive: isActive, // KIRIM STATUS
          );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Perubahan'),
              content: Text(
                'Anda akan mengubah jadwal ambil obat pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Perbarui'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        await _medicationRefillService.updateRefillSchedule(
          editId!,
          updateSchedule,
        ); // 🔥 Update Refill

        if (!mounted) return;
        Navigator.pop(context); // Close loading

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Jadwal ambil obat pada $selectedDate berhasil diubah.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading

        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal mengubah jadwal ambil obat: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    } else {
      // --- MODE CREATE ---
      final CreateMedicationRefillDTO newSchedule = CreateMedicationRefillDTO(
        refillDate: apiDateFormat,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Pembuatan'),
              content: Text(
                'Anda akan membuat jadwal ambil obat pada tanggal $selectedDate. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Buat'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        await _medicationRefillService.createRefillSchedule(
          newSchedule,
        ); // 🔥 Create Refill

        if (!mounted) return;
        Navigator.pop(context);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Berhasil'),
                content: Text(
                  'Jadwal ambil obat pada $selectedDate berhasil dibuat.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Gagal 😔'),
                content: Text(
                  'Gagal membuat jadwal ambil obat: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // --- FIELD WIDGETS ---

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kategori',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            key: const ValueKey('categoryDropdown'),
            value: selectedCategory,
            hint: const Text('Pilih kategori pengingat'),
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none),
            items:
                categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['value'],
                    enabled: !isEditMode,
                    child: Row(
                      children: [
                        Icon(
                          category['icon'],
                          size: 20,
                          color: isEditMode ? Colors.grey : AppColors.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category['label'],
                          style: TextStyle(
                            color: isEditMode ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged:
                isEditMode
                    ? null
                    : (value) {
                      setState(() {
                        selectedCategory = value;
                        // Reset fields yang tidak relevan (terutama untuk Drug)
                        drugNameController.clear();
                        doseController.text = '1';
                        at06 = false;
                        at12 = false;
                        at18 = false;
                        isActive = true;

                        // Pastikan tanggal tidak di-reset di mode create, hanya di-reset jika pindah kategori
                        if (selectedDate == null) {
                          DateTime now = DateTime.now();
                          selectedDate =
                              "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
                          dateController.text = selectedDate!;
                        }
                      });
                    },
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Kategori wajib dipilih';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMinumObatFields() {
    final bool isToday =
        selectedDate != null &&
        _convertDisplayDateToDateTime(selectedDate!).isAtSameMomentAs(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );

    final bool is06Available = !isToday || _isTimeSlotAvailable(6);
    final bool is12Available = !isToday || _isTimeSlotAvailable(12);
    final bool is18Available = !isToday || _isTimeSlotAvailable(18);

    if (!is06Available && at06) at06 = false;
    if (!is12Available && at12) at12 = false;
    if (!is18Available && at18) at18 = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Nama Obat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: drugNameController,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama obat',
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Nama obat wajib diisi';
              return null;
            },
            onChanged: (value) => drugName = value,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dosis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: doseController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Masukkan dosis',
              suffixText: 'Tablet',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Dosis wajib diisi';
              if (int.tryParse(value) == null || int.parse(value) <= 0)
                return 'Dosis harus angka positif';
              return null;
            },
            onChanged: (value) => dose = value,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pilih Tanggal Mulai',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate ?? 'Pilih tanggal mulai pengingat',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pilih Jam Pengingat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTimeCheckbox(
          title: 'Pagi (06:00)',
          value: at06,
          onChanged: is06Available ? (v) => setState(() => at06 = v!) : null,
          isDisabled: !is06Available,
        ),
        _buildTimeCheckbox(
          title: 'Siang (12:00)',
          value: at12,
          onChanged: is12Available ? (v) => setState(() => at12 = v!) : null,
          isDisabled: !is12Available,
        ),
        _buildTimeCheckbox(
          title: 'Sore (18:00)',
          value: at18,
          onChanged: is18Available ? (v) => setState(() => at18 = v!) : null,
          isDisabled: !is18Available,
        ),

        // TOGGLE STATUS (khusus mode edit)
        if (isEditMode) _buildStatusToggle(),
      ],
    );
  }

  Widget _buildTimeCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?>? onChanged,
    required bool isDisabled,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDisabled ? Colors.grey.shade400 : Colors.white,
        ),
      ),
      value: value,
      onChanged: onChanged,
      checkColor: Colors.white,
      activeColor: AppColors.tertiary,
      tileColor: isDisabled ? Colors.transparent : null,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildKontrolFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Pilih Tanggal Kontrol',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate ?? 'Pilih tanggal kontrol',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),

        // TOGGLE STATUS (khusus mode edit)
        if (isEditMode) _buildStatusToggle(),
      ],
    );
  }

  Widget _buildHemodialisisFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Pilih Tanggal Hemodialisis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate ?? 'Pilih tanggal hemodialisis',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),

        // TOGGLE STATUS (khusus mode edit)
        if (isEditMode) _buildStatusToggle(),
      ],
    );
  }

  // 🔥 WIDGET BARU: Field Khusus Medication Refill
  Widget _buildMedicationRefillFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Pilih Tanggal Ambil Obat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate ?? 'Pilih tanggal ambil obat',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),

        // TOGGLE STATUS (khusus mode edit)
        if (isEditMode) _buildStatusToggle(),
      ],
    );
  }

  // Widget Pembantu untuk Toggle Status (Digunakan oleh Kontrol, Hemodialisis, Refill)
  Widget _buildStatusToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Status Pengingat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isActive ? 'Aktif' : 'Tidak Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
                activeColor: AppColors.tertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      isEditMode ? 'EDIT PENGINGAT' : 'BUAT PENGINGAT',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryField(),
                    if (selectedCategory == 'minum_obat')
                      _buildMinumObatFields()
                    else if (selectedCategory == 'kontrol')
                      _buildKontrolFields()
                    else if (selectedCategory == 'hemodialisis')
                      _buildHemodialisisFields()
                    else if (selectedCategory ==
                        'refill') // 🔥 Integrasi Refill
                      _buildMedicationRefillFields(),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (!isEditMode) ...[
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: isEditMode ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEditMode ? 'SIMPAN PERUBAHAN' : 'BUAT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    drugNameController.dispose();
    doseController.dispose();
    super.dispose();
  }
}
