# 🏞️ TIRTHA App

## 📁 Struktur Folder dan Arsitektur Aplikasi Flutter

### 🧩 Struktur Utama Folder
```bash
lib/
├── core/
├── data/
├── domain/
├── presentation/
├── di/
├── routes/
├── main.dart


### Penjelasan Setiap Folder
``bash 📦 core/ ``
Folder ini berisi kode-kode inti yang digunakan di seluruh aplikasi, tetapi tidak spesifik untuk domain bisnis tertentu:
📦 core/
│
├── config/
│   ├── app_constants.dart      # Variabel konstan global (misal: URL API)
│   ├── app_theme.dart          # Konfigurasi tema visual aplikasi
│   └── app_routes.dart         # Definisi rute aplikasi
│
├── services/
│   ├── api_service.dart        # Kelas dasar untuk melakukan panggilan API
│   └── local_storage_service.dart  # Layanan untuk penyimpanan lokal
│
└── utils/
    ├── validators.dart         # Fungsi-fungsi validasi input
    └── date_formatter.dart     # Fungsi format tanggal dan waktu



services/: Berisi layanan-layanan eksternal atau utilitas yang tidak secara langsung terkait dengan logika bisnis.

api_service.dart: Kelas dasar untuk melakukan panggilan API.
local_storage_service.dart: Layanan untuk berinteraksi dengan penyimpanan lokal.


utils/: Berisi fungsi-fungsi pembantu (helper) yang dapat digunakan di mana saja.

validators.dart: Fungsi-fungsi untuk validasi input.
date_formatter.dart: Fungsi untuk format tanggal dan waktu.




💾 data/
Lapisan ini bertanggung jawab untuk berinteraksi dengan sumber data eksternal, seperti API, database, atau penyimpanan lokal.
Subfolder:

models/: Berisi Models atau Data Transfer Objects (DTO). Kelas-kelas ini merepresentasikan struktur data mentah yang diterima dari API atau sumber eksternal lainnya (contoh: JSON).
repositories/: Berisi implementasi dari Repositories. Tugasnya adalah mengambil data dari sumber eksternal (menggunakan Models) dan mengubahnya menjadi Entities sebelum diberikan ke lapisan domain.


🎯 domain/
Lapisan ini adalah inti dari aplikasi, yang berisi seluruh logika bisnis dan aturan-aturan aplikasi. Lapisan ini sepenuhnya independen dari teknologi.
Subfolder:

entities/: Berisi Entities. Kelas-kelas ini adalah objek bisnis murni yang hanya berisi data dan logika bisnis dasar. Mereka tidak peduli dari mana data berasal atau bagaimana data akan ditampilkan.
usecases/: Berisi Use Cases. Setiap Use Case merepresentasikan satu alur bisnis spesifik, seperti fetch_user_usecase.dart yang bertanggung jawab untuk mengambil data pengguna.


🎨 presentation/
Lapisan ini adalah lapisan teratas yang berinteraksi langsung dengan pengguna. Ini berisi seluruh elemen UI dan manajemen state.
Subfolder:

pages/: Berisi Widget yang merepresentasikan halaman atau layar aplikasi.

home/: Contoh folder untuk satu halaman, yang bisa berisi home_page.dart (UI), home_viewmodel.dart (logic), dan file lain untuk manajemen state (contoh: BLoC event/state).


widgets/: Berisi Widget yang dapat digunakan kembali di seluruh aplikasi.
themes/: Berisi konfigurasi visual seperti warna dan tipografi.

colors.dart: Palet warna aplikasi.
typography.dart: Gaya teks dan font.




🔌 di/
Folder ini digunakan untuk mengelola Dependency Injection (DI), yang membuat kode lebih mudah diuji dan dikelola. Di sini, kita mendaftarkan semua dependensi (seperti ViewModel, Repository, dan Use Case) agar dapat digunakan di seluruh aplikasi.

dependency_injection.dart: Berisi konfigurasi untuk library DI (misal: get_it).


🧭 routes/
Folder ini mengelola seluruh navigasi dan routing aplikasi secara terpusat, menggunakan library seperti go_router.

app_router.dart: Definisi semua rute dan logika navigasi.