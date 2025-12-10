SearchCost

Aplikasi mobile untuk pencarian dan pengecekan harga barang secara cepat dan akurat. Dikembangkan menggunakan Flutter dengan integrasi penuh ke Firebase untuk autentikasi, database, dan penyimpanan.

Fitur Utama

Autentikasi

Login menggunakan email dan password

Login menggunakan akun Google

Registrasi dengan tambahan username

Pencarian Harga

Scan barcode secara langsung

Pencarian manual barang

Riwayat pencarian tersimpan otomatis

Dashboard Admin

Manajemen data barang

Manajemen pengguna

Ringkasan laporan yang diperbarui secara realtime

Integrasi Backend

Firebase Authentication

Cloud Firestore

Firebase Storage

Struktur Proyek
app_search_cost/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── models/
│
├── android/
├── ios/
├── web_public/
└── pubspec.yaml

Teknologi

Flutter (Dart)

Firebase (Auth, Firestore, Storage)

Google Sign-In

Barcode / QR Scanner

Cloud Hosting (opsional)

Menjalankan Proyek

Clone repository:

git clone <url-repo>


Masuk ke folder aplikasi:

cd app_search_cost


Install dependensi:

flutter pub get


Jalankan aplikasi:

flutter run

Konfigurasi Firebase

Pastikan file berikut tersedia:

Android

android/app/google-services.json


Web

web_public/js/firebase-config.js


Jika belum ada, unduh dari Firebase Console dan letakkan di path yang sesuai.

Build Release

Android

flutter build apk --release


Output tersedia di:

build/app/outputs/flutter-apk/

Lisensi

Proyek ini digunakan untuk kebutuhan pengembangan internal.
Lisensi dapat ditambahkan sesuai ketentuan penggunaan yang diinginkan.
