SearchCost

Aplikasi mobile untuk melakukan pencarian, pengecekan, dan pengelolaan data harga barang secara cepat dan akurat. Dibangun menggunakan Flutter dengan integrasi Firebase untuk autentikasi, database, dan layanan backend lainnya.

Fitur Utama

Login dan registrasi menggunakan email, username, atau Google Account

Scan barcode untuk menemukan harga barang secara instan

Riwayat pencarian yang tersimpan otomatis

Dashboard admin untuk mengatur dan memantau data barang dan pengguna

Integrasi penuh dengan Firebase: Authentication, Firestore, Storage

Tampilan antarmuka yang ringan dan responsif

Struktur Proyek
app_search_cost/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   └── models/
│
├── android/
├── ios/
├── web_public/
└── pubspec.yaml

Teknologi yang Digunakan

Flutter (Dart)

Firebase Authentication

Cloud Firestore

Firebase Storage

Google Sign-In

Camera & Barcode Scanner plugins

Cara Menjalankan Proyek

Pastikan Flutter sudah ter-install.

Clone repository:

git clone <url-repo>


Masuk ke folder proyek:

cd app_search_cost


Install dependency:

flutter pub get


Jalankan aplikasi:

flutter run

Konfigurasi Firebase

Pastikan file berikut sudah terpasang:

android/app/google-services.json

web_public/js/firebase-config.js

Jika tidak, setup melalui Firebase Console dan download file konfigurasi.

Build APK Release
flutter build apk --release


Hasil dapat ditemukan di:

build/app/outputs/flutter-apk/

Lisensi

Proyek ini dibuat untuk kebutuhan internal dan pengembangan lebih lanjut.
Lisensi dapat ditambahkan sesuai kebutuhan.
