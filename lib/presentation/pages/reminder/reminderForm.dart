import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/core/services/drug_schedule_service.dart';
import 'package:tirtha_app/core/services/control_schedule_service.dart';
import 'package:tirtha_app/core/services/hemodialysis_schedule_service.dart';
import 'package:tirtha_app/data/models/drug_schedule_model.dart';
import 'package:tirtha_app/data/models/control_schedule_model.dart';
import 'package:tirtha_app/data/models/hemodialysis_schedule_model.dart';

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
  String? selectedTime;

  String drugName = '';
  String dose = '1 Tablet';
  bool at06 = false;
  bool at12 = false;
  bool at18 = false;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController doseController = TextEditingController(text: '1');

  final DrugScheduleService _drugScheduleService = DrugScheduleService();
  final ControlScheduleService _controlScheduleService = ControlScheduleService();
  final HemodialysisScheduleService _hemodialysisScheduleService = HemodialysisScheduleService();

  bool isEditMode = false;
  int? editId;

  void _safeCloseDialog() {
    if (mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        print('Error closing dialog: $e');
      }
    }
  }

  Future<void> _safeShowDialog(Widget dialog) async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    showDialog(context: context, builder: (_) => dialog);
  }

  final List<Map<String, dynamic>> categories = [
    {'value': 'minum_obat', 'label': 'Jadwal Minum Obat', 'icon': Icons.medication},
    {'value': 'kontrol', 'label': 'Jadwal Kontrol', 'icon': Icons.local_hospital},
    {'value': 'hemodialisis', 'label': 'Jadwal Hemodialisis', 'icon': Icons.water_drop},
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.editData != null) {
      isEditMode = true;
      _loadEditData();
    } else {
      DateTime now = DateTime.now();
      selectedDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      dateController.text = selectedDate!;
    }
  }

  void _loadEditData() {
    final data = widget.editData;
    
    if (data is DrugScheduleResponseDTO) {
      selectedCategory = 'minum_obat';
      editId = data.id;
      drugNameController.text = data.drugName;
      
      final doseMatch = RegExp(r'\d+').firstMatch(data.dose);
      if (doseMatch != null) {
        doseController.text = doseMatch.group(0)!;
      }
      
      at06 = data.at06;
      at12 = data.at12;
      at18 = data.at18;
      
      selectedDate = _convertDateFromAPI(data.scheduleDate);
      dateController.text = selectedDate!;
      
    } else if (data is ControlScheduleResponseDTO) {
      selectedCategory = 'kontrol';
      editId = data.id;
      selectedDate = _convertDateFromAPI(data.controlDate);
      dateController.text = selectedDate!;
      
    } else if (data is HemodialysisScheduleResponseDTO) {
      selectedCategory = 'hemodialisis';
      editId = data.id;
      selectedDate = _convertDateFromAPI(data.scheduleDate);
      dateController.text = selectedDate!;
    }
  }

  String _convertDateFromAPI(String apiDate) {
    try {
      final parts = apiDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      print('⚠️ Date conversion error: $e');
    }
    return apiDate;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
        selectedDate = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        dateController.text = selectedDate!;
      });
    }
  }

  void _handleReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Reset'),
        content: const Text('Apakah Anda yakin ingin mereset semua isian form?'),
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
                dose = '1 Tablet';
                at06 = false;
                at12 = false;
                at18 = false;
                selectedDate = null;
                selectedTime = null;
                drugNameController.clear();
                doseController.text = '1';
                dateController.clear();
                timeController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Form berhasil di-reset')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String convertDateFormat(String ddMMyyyyDate) {
    try {
      final parts = ddMMyyyyDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      print('⚠️ Date conversion error: $e');
    }
    return ddMMyyyyDate;
  }

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
    }
  }

  Future<void> _handleDrugScheduleSubmit() async {
    if (!at06 && !at12 && !at18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu jam pengingat obat')),
      );
      return;
    }

    final String apiDateFormat = convertDateFormat(selectedDate ?? dateController.text);

    if (isEditMode && editId != null) {
      final UpdateDrugScheduleDTO updateSchedule = UpdateDrugScheduleDTO(
        drugName: drugNameController.text,
        dose: doseController.text + ' Tablet',
        scheduleDate: apiDateFormat,
        at06: at06,
        at12: at12,
        at18: at18,
      );

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Update'),
          content: Text('Anda akan mengubah jadwal obat "${updateSchedule.drugName}" dengan dosis ${updateSchedule.dose} pada tanggal ${selectedDate}. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(context: context, barrierDismissible: false, builder: (loadingContext) => const Center(child: CircularProgressIndicator()));

                try {
                  await _drugScheduleService.updateDrugSchedule(editId.toString(), updateSchedule);
                  _safeCloseDialog();
                  await _safeShowDialog(
                    AlertDialog(
                      title: const Text('Berhasil 🎉'),
                      content: Text('Pengingat obat ${updateSchedule.drugName} berhasil diubah.'),
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
                  _safeCloseDialog();
                  await _safeShowDialog(
                    AlertDialog(
                      title: const Text('Gagal 😔'),
                      content: Text('Gagal mengubah pengingat obat: ${e.toString()}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
              child: const Text('Update'),
            ),
          ],
        ),
      );
    } else {
      final CreateDrugScheduleDTO newSchedule = CreateDrugScheduleDTO(
        drugName: drugNameController.text,
        dose: doseController.text + ' Tablet',
        scheduleDate: apiDateFormat,
        at06: at06,
        at12: at12,
        at18: at18,
      );

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Pembuatan'),
          content: Text('Anda akan membuat jadwal obat "${newSchedule.drugName}" dengan dosis ${newSchedule.dose} pada tanggal ${selectedDate}. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(context: context, barrierDismissible: false, builder: (loadingContext) => const Center(child: CircularProgressIndicator()));

                try {
                  final response = await _drugScheduleService.createDrugSchedule(newSchedule);
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Berhasil 🎉'),
                      content: Text('Pengingat obat ${response.drugName} berhasil dibuat.'),
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
                    builder: (context) => AlertDialog(
                      title: const Text('Gagal 😔'),
                      content: Text('Gagal membuat pengingat obat: ${e.toString()}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
              child: const Text('Buat'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleControlScheduleSubmit() async {
    if (selectedDate == null || selectedDate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal kontrol')));
      return;
    }

    final String apiDateFormat = convertDateFormat(selectedDate!);

    if (isEditMode && editId != null) {
      final UpdateControlScheduleDTO updateSchedule = UpdateControlScheduleDTO(controlDate: apiDateFormat);

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Update'),
          content: Text('Anda akan mengubah jadwal kontrol pada tanggal $selectedDate. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(context: context, barrierDismissible: false, builder: (loadingContext) => const Center(child: CircularProgressIndicator()));

                try {
                  await _controlScheduleService.updateControlSchedule(editId!, updateSchedule);
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Berhasil 🎉'),
                      content: Text('Jadwal kontrol pada ${selectedDate} berhasil diubah.'),
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
                    builder: (context) => AlertDialog(
                      title: const Text('Gagal 😔'),
                      content: Text('Gagal mengubah jadwal kontrol: ${e.toString()}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
              child: const Text('Update'),
            ),
          ],
        ),
      );
    } else {
      final CreateControlScheduleDTO newSchedule = CreateControlScheduleDTO(controlDate: apiDateFormat);

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Pembuatan'),
          content: Text('Anda akan membuat jadwal kontrol pada tanggal $selectedDate. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(context: context, barrierDismissible: false, builder: (loadingContext) => const Center(child: CircularProgressIndicator()));

                try {
                  final response = await _controlScheduleService.createControlSchedule(newSchedule);
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Berhasil 🎉'),
                      content: Text('Jadwal kontrol pada ${selectedDate} berhasil dibuat.'),
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
                    builder: (context) => AlertDialog(
                      title: const Text('Gagal 😔'),
                      content: Text('Gagal membuat jadwal kontrol: ${e.toString()}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
              child: const Text('Buat'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleHemodialysisScheduleSubmit() async {
    if (selectedDate == null || selectedDate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal hemodialisis')));
      return;
    }

    final String apiDateFormat = convertDateFormat(selectedDate!);

    if (isEditMode && editId != null) {
      final UpdateHemodialysisScheduleDTO updateSchedule = UpdateHemodialysisScheduleDTO(scheduleDate: apiDateFormat);

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Update'),
          content: Text('Anda akan mengubah jadwal hemodialisis pada tanggal $selectedDate. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(context: context, barrierDismissible: false, builder: (loadingContext) => const Center(child: CircularProgressIndicator()));

                try {
                  await _hemodialysisScheduleService.updateHemodialysisSchedule(editId!, updateSchedule);
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Berhasil 🎉'),
                      content: Text('Jadwal hemodialisis pada ${selectedDate} berhasil diubah.'),
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
                    builder: (context) => AlertDialog(
                      title: const Text('Gagal 😔'),
                      content: Text('Gagal mengubah jadwal hemodialisis: ${e.toString()}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
              child: const Text('Update'),
            ),
          ],
        ),
      );
    } else {
      final CreateHemodialysisScheduleDTO newSchedule = CreateHemodialysisScheduleDTO(scheduleDate: apiDateFormat);

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Pembuatan'),
          content: Text('Anda akan membuat jadwal hemodialisis pada tanggal $selectedDate. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(context: context, barrierDismissible: false, builder: (loadingContext) => const Center(child: CircularProgressIndicator()));

                try {
                  final response = await _hemodialysisScheduleService.createHemodialysisSchedule(newSchedule);
                  if (!mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Berhasil 🎉'),
                      content: Text('Jadwal hemodialisis pada ${selectedDate} berhasil dibuat.'),
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
                    builder: (context) => AlertDialog(
                      title: const Text('Gagal 😔'),
                      content: Text('Gagal membuat jadwal hemodialisis: ${e.toString()}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.tertiary),
              child: const Text('Buat'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Kategori', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonFormField<String>(
            key: const ValueKey('categoryDropdown'),
            value: selectedCategory,
            hint: const Text('Pilih kategori pengingat'),
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['value'],
                enabled: !isEditMode,
                child: Row(
                  children: [
                    Icon(category['icon'], size: 20, color: isEditMode ? Colors.grey : AppColors.secondary),
                    const SizedBox(width: 12),
                    Text(category['label'], style: TextStyle(color: isEditMode ? Colors.grey : Colors.black)),
                  ],
                ),
              );
            }).toList(),
            onChanged: isEditMode ? null : (value) {
              setState(() {
                selectedCategory = value;
                drugNameController.clear();
                doseController.text = '1';
                at06 = false;
                at12 = false;
                at18 = false;
                selectedTime = null;
                timeController.clear();
                DateTime now = DateTime.now();
                selectedDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
                dateController.text = selectedDate!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Kategori wajib dipilih';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMinumObatFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Nama Obat', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: TextFormField(
            controller: drugNameController,
            decoration: const InputDecoration(hintText: 'Masukkan nama obat', border: InputBorder.none),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nama obat wajib diisi';
              return null;
            },
            onChanged: (value) => drugName = value,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Dosis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: TextFormField(
            controller: doseController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Masukkan dosis', suffixText: 'Tablet'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Dosis wajib diisi';
              if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Dosis harus angka positif';
              return null;
            },
            onChanged: (value) => dose = value,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Pilih Tanggal Mulai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedDate ?? 'Pilih tanggal mulai pengingat', style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey)),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Pilih Jam Pengingat', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTimeCheckbox(title: 'Pagi (06:00 WIB)', value: at06, onChanged: (v) => setState(() => at06 = v!)),
        _buildTimeCheckbox(title: 'Siang (12:00 WIB)', value: at12, onChanged: (v) => setState(() => at12 = v!)),
        _buildTimeCheckbox(title: 'Sore (18:00 WIB)', value: at18, onChanged: (v) => setState(() => at18 = v!)),
      ],
    );
  }

  Widget _buildTimeCheckbox({required String title, required bool value, required ValueChanged<bool?> onChanged}) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      checkColor: Colors.white,
      activeColor: AppColors.tertiary,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildKontrolFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Pilih Tanggal Kontrol', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedDate ?? 'Pilih tanggal kontrol', style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey)),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHemodialisisFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Pilih Tanggal Hemodialisis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedDate ?? 'Pilih tanggal hemodialisis', style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey)),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
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
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                      _buildHemodialisisFields(),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('RESET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isEditMode ? 'UPDATE' : 'BUAT', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    timeController.dispose();
    drugNameController.dispose();
    doseController.dispose();
    super.dispose();
  }
}