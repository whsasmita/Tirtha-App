import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';
import 'package:tirtha_app/presentation/widgets/top_bar.dart';

class ReminderFormPage extends StatefulWidget {
  const ReminderFormPage({Key? key}) : super(key: key);

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  String? selectedCategory;
  String? selectedDate;
  String? selectedTime;
  int dosage = 1;
  
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  
  // Kategori pengingat
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
  ];

  // Pilihan jam untuk minum obat
  final List<String> timeSlots = [
    'Pagi (06:00 WIB)',
    'Siang (12:00 WIB)',
    'Sore (18:00 WIB)',
  ];

  String? selectedTimeSlot;

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
        selectedDate = "${picked.day}-${picked.month}-${picked.year}";
        dateController.text = selectedDate!;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
        selectedTime = picked.format(context);
        timeController.text = selectedTime!;
      });
    }
  }

  void _handleReset() {
    setState(() {
      selectedCategory = null;
      selectedDate = null;
      selectedTime = null;
      selectedTimeSlot = null;
      dosage = 1;
      dateController.clear();
      timeController.clear();
    });
  }

  void _handleSubmit() {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    // Validasi berdasarkan kategori
    if (selectedCategory == 'minum_obat') {
      if (selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih waktu minum obat')),
        );
        return;
      }
    } else {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal')),
        );
        return;
      }
    }

    // Tampilkan dialog sukses
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: const Text('Pengingat berhasil dibuat'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
          child: DropdownButton<String>(
            value: selectedCategory,
            hint: const Text('Pilih kategori pengingat'),
            isExpanded: true,
            underline: const SizedBox(),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['value'],
                child: Row(
                  children: [
                    Icon(category['icon'], size: 20, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    Text(category['label']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                // Reset form saat kategori berubah
                selectedDate = null;
                selectedTime = null;
                selectedTimeSlot = null;
                dosage = 1;
                dateController.clear();
                timeController.clear();
              });
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
        const Text(
          'Pilih Tanggal',
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
          child: DropdownButton<String>(
            value: selectedTimeSlot,
            hint: const Text('Pilih tanggal pengingat'),
            isExpanded: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: 'daily',
                child: Text('Setiap hari'),
              ),
              DropdownMenuItem(
                value: 'weekdays',
                child: Text('Hari kerja (Senin-Jumat)'),
              ),
              DropdownMenuItem(
                value: 'custom',
                child: Text('Pilih tanggal'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedTimeSlot = value;
              });
            },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: dosage.toString()),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Masukkan dosis',
                    suffixText: 'Tablet',
                  ),
                  onChanged: (value) {
                    dosage = int.tryParse(value) ?? 1;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pilih Jam',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...timeSlots.map((slot) {
          return RadioListTile<String>(
            value: slot,
            groupValue: selectedTimeSlot,
            title: Text(slot, style: const TextStyle(color: Colors.white)),
            activeColor: AppColors.tertiary,
            onChanged: (value) {
              setState(() {
                selectedTimeSlot = value;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildKontrolFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Pilih Tanggal',
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
                  selectedDate ?? 'Pilih tanggal pengingat',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
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
        const Text(
          'Hari',
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
              children: [
                const Icon(Icons.add, color: AppColors.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate ?? 'Pilih hari kontrol',
                    style: TextStyle(
                      color: selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        selectedDate = null;
                        dateController.clear();
                      });
                    },
                  ),
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
          // Header dengan SafeArea untuk melindungi dari notch/camera
          SafeArea(
            bottom: false, // Tidak perlu SafeArea di bawah untuk header
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'BUAT PENGINGAT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryField(),
                  
                  // Dynamic fields based on category
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

          // Bottom Buttons dengan SafeArea untuk melindungi dari gesture bar
          SafeArea(
            top: false, // Tidak perlu SafeArea di atas untuk tombol
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
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
                  Expanded(
                    flex: 2,
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
                      child: const Text(
                        'BUAT',
                        style: TextStyle(
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
    timeController.dispose();
    super.dispose();
  }
}