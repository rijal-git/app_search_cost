# **SearchCost**

SearchCost adalah aplikasi pencarian dan analisis harga barang yang dirancang untuk memberikan pengalaman tercepat dan paling praktis dalam menemukan informasi harga.
Aplikasi ini dibangun menggunakan Flutter, dipadukan dengan infrastruktur Firebase yang stabil dan real-time.

Setiap fitur dioptimalkan untuk kecepatan, akurasi, dan efisiensi penggunaan.

---

## **Gambaran Umum**

SearchCost mendukung proses pencarian harga melalui pemindaian barcode, input manual, serta penyediaan riwayat pencarian yang tersusun otomatis.
Sistem autentikasi fleksibel, mendukung login menggunakan email atau akun Google, termasuk pendaftaran dengan username khusus untuk identitas pengguna.

---

## **Fitur Utama**

**1. Autentikasi Modern**

* Login via email dan password
* Login Google
* Registrasi dengan username untuk identitas tampilan

**2. Pencarian dan Pemindaian**

* Pemindaian barcode langsung
* Pencarian manual
* Penyimpanan otomatis riwayat pencarian

**3. Dashboard Administrator**

* Pengelolaan data barang
* Pengelolaan pengguna
* Ringkasan laporan berbasis Firestore secara real-time

**4. Integrasi Firebase**

* Authentication
* Cloud Firestore
* Storage untuk media
* Hosting opsional untuk web frontend

---

## **Struktur Proyek**

```
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
```

Struktur dibuat agar mudah diperluas dan dipelihara pada pengembangan jangka panjang.

---

## **Teknologi Inti**

* Framework: Flutter (Dart)
* Backend: Firebase
* Autentikasi: Email/Password, Google Sign-In
* Database: Firestore
* Penyimpanan: Firebase Storage
* Scanner: Camera + Barcode Analysis

---

## **Menjalankan Proyek**

1. Clone repository:

   ```
   git clone <url-repo>
   ```
2. Masuk ke folder:

   ```
   cd app_search_cost
   ```
3. Install dependence:

   ```
   flutter pub get
   ```
4. Jalankan aplikasi:

   ```
   flutter run
   ```

---

## **Konfigurasi Firebase**

Berkas konfigurasi yang diperlukan:

**Android**

```
android/app/google-services.json
```

**Web**

```
web_public/js/firebase-config.js
```

Jika belum tersedia, unduh melalui Firebase Console.

---

## **Build Release**

Jalankan:

```
flutter build apk --release
```

Hasil berada di:

```
build/app/outputs/flutter-apk/
```

---

## **Lisensi**

Proyek ini dikembangkan untuk keperluan aplikasi internal dan dapat diperluas sesuai kebutuhan operasional.
Ketentuan lisensi dapat ditambahkan jika aplikasi dirilis secara publik.

---
