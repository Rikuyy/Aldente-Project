# CookCash

**CookCash** adalah aplikasi rekomendasi resep dan pencatatan budget makan berbasis mobile untuk membantu mahasiswa indekos dalam mengelola kebutuhan makan harian secara lebih praktis, hemat, dan terencana.

Aplikasi ini menggunakan metode **TF-IDF** dan **Cosine Similarity** untuk memberikan rekomendasi resep berdasarkan input pengguna, serta dilengkapi dengan fitur pencatatan keuangan, inventory bahan makanan, dan jadwal memasak.

---

## Tim Pengembang

**Kebon Almastrip**

| Nama | NIM/Kelas | Role | GitHub |
|---|---|---|---|
| Rifky Trio Saputra | E31240807 / B | Ketua, Backend Mobile | [@Rikuyy](https://github.com/Rikuyy) |
| Ratna Dwiyati Ningsih | E31240813 / B | Backend Web | [@rnnaaa](https://github.com/rnnaaa) |
| Ovi Octa Rama Dhani | E31242213 / D | Backend Mobile | [@oviocta](https://github.com/oviocta) |
| Muh. Rendi Kurniawan | E31240858 / B | Frontend Mobile | [@RerendiKurr05](https://github.com/RerendiKurr05) |
| Nabil Zivkolin Danendra | E31240615 / B | Frontend Web | [@nabeeldndraa](https://github.com/nabeeldndraa) |

---

## Deskripsi Project

CookCash merupakan aplikasi yang dirancang untuk membantu mahasiswa indekos dalam menentukan menu masakan harian berdasarkan bahan, kebutuhan, dan preferensi pengguna.

Aplikasi ini berpusat pada **Dashboard** yang menampilkan ringkasan saldo atau dompet pengguna serta rekomendasi resep harian. Pengguna juga dapat menggunakan fitur **Consultation Page** untuk berdiskusi dengan chatbot CookCash dalam mencari rekomendasi resep yang lebih spesifik.

Selain fitur rekomendasi resep, CookCash juga menyediakan fitur **Manajemen Keuangan**, **Inventory Bahan Makanan**, dan **To-Do Cook Schedule** agar pengguna dapat mengatur pengeluaran makan, stok bahan, serta jadwal memasak dengan lebih mudah.

---

## Gambaran Umum Sistem

Gambar berikut menunjukkan arsitektur umum sistem CookCash.

<p align="center">
  <img src="assets/images/overall-system.png" alt="Overall System CookCash" width="700">
</p>

---

## Fitur Utama

### 1. Dashboard Cerdas

Menampilkan ringkasan saldo atau dompet pengguna, rekomendasi resep harian, serta informasi penting terkait aktivitas pengguna.

### 2. Consultation Page

Fitur chatbot yang membantu pengguna mendapatkan rekomendasi resep berdasarkan bahan, kebutuhan, atau keinginan pengguna.

Fitur ini didukung oleh:

- Gemini API
- Flask API
- TF-IDF
- Cosine Similarity

### 3. Manajemen Keuangan

Mencatat pemasukan dan pengeluaran pengguna secara detail, terutama untuk kebutuhan makan harian.

Fitur ini juga dilengkapi dengan visualisasi grafik agar pengguna dapat memantau arus keuangan dengan lebih jelas.

### 4. Inventory / Stok Bahan

Membantu pengguna mencatat bahan makanan yang tersedia secara manual, sehingga pengguna dapat mengetahui stok bahan yang dimiliki.

### 5. To-Do Cook Schedule

Fitur jadwal memasak yang memungkinkan pengguna mengatur menu harian. Menu dapat ditambahkan atau diubah melalui halaman konsultasi maupun rekomendasi dari dashboard.

---

## Tech Stack

| Bagian | Teknologi |
|---|---|
| Mobile App | Flutter |
| Backend API & Web | Laravel |
| Database | MongoDB |
| Machine Learning API | Python Flask |
| Machine Learning Method | TF-IDF & Cosine Similarity |
| Library ML | Scikit-Learn |
| Third-Party API | Google Gemini API |

---

## Prasyarat Sistem

Sebelum menjalankan project ini, pastikan perangkat sudah memiliki beberapa software berikut:

- [Git](https://git-scm.com/)
- [PHP 8.2+](https://www.php.net/)
- [Composer](https://getcomposer.org/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python 3.9+](https://www.python.org/)
- [MongoDB](https://www.mongodb.com/)
- API Key dari [Google AI Studio](https://aistudio.google.com/)

---

## Cara Instalasi dan Menjalankan Project

### 1. Clone Repository

```bash
git clone https://github.com/Rikuyy/Aldente-Project.git
cd Aldente-Project
```

> Catatan: Repository ini menggunakan struktur monorepo yang berisi folder Laravel, API, dan Flutter.

---

### 2. Konfigurasi Database MongoDB

Pastikan service MongoDB sudah berjalan di perangkat lokal.

Buat database baru dengan nama:

```bash
cookcash_db
```

Database dapat dibuat melalui MongoDB Compass atau melalui terminal MongoDB.

---

### 3. Setup Backend Laravel

Masuk ke folder Laravel:

```bash
cd Laravel
```

Install dependency Laravel:

```bash
composer install
```

Copy file environment:

```bash
cp .env.example .env
```

Untuk Windows PowerShell, gunakan:

```bash
copy .env.example .env
```

Atur konfigurasi database pada file `.env`:

```env
DB_CONNECTION=mongodb
DB_HOST=127.0.0.1
DB_PORT=27017
DB_DATABASE=cookcash_db
```

Generate application key:

```bash
php artisan key:generate
```

Jalankan server Laravel:

```bash
php artisan serve
```

Backend Laravel akan berjalan di:

```bash
http://localhost:8000
```

---

### 4. Setup API Machine Learning dan Chatbot

Buka terminal baru, lalu masuk ke folder API:

```bash
cd API
```

Buat virtual environment:

```bash
python -m venv venv
```

Aktifkan virtual environment.

Untuk Windows:

```bash
venv\Scripts\activate
```

Untuk Mac/Linux:

```bash
source venv/bin/activate
```

Install dependency Python:

```bash
pip install -r requirements.txt
```

Buat file `.env` di dalam folder API, lalu tambahkan Gemini API Key:

```env
GEMINI_API_KEY=masukkan_api_key_anda_di_sini
```

Jalankan server Flask:

```bash
python app.py
```

API Machine Learning akan berjalan di:

```bash
http://localhost:5000
```

---

### 5. Setup Mobile App Flutter

Buka terminal baru, lalu masuk ke folder Flutter:

```bash
cd Flutter
```

Ambil dependency Flutter:

```bash
flutter pub get
```

Sesuaikan Base URL API pada file konfigurasi API, misalnya:

```bash
Flutter/lib/services/api_service.dart
```

Pastikan Base URL mengarah ke alamat IP lokal komputer.

Contoh:

```dart
http://192.168.1.x:8000
```

> Jangan menggunakan `localhost` jika aplikasi dijalankan melalui emulator atau perangkat fisik Android.

Jalankan aplikasi:

```bash
flutter run
```

---

## Struktur Project

```bash
Aldente-Project/
├── Laravel/
│   └── Backend API dan Web Admin
├── API/
│   └── Flask API untuk Machine Learning dan Chatbot
├── Flutter/
│   └── Aplikasi Mobile CookCash
└── README.md
```

---

## Metode Rekomendasi

CookCash menggunakan metode **TF-IDF** dan **Cosine Similarity** untuk mencocokkan input pengguna dengan data resep yang tersedia.

Secara umum, proses rekomendasi dilakukan dengan tahapan berikut:

1. Pengguna memasukkan bahan makanan atau kebutuhan resep.
2. Sistem mengubah data teks menjadi representasi numerik menggunakan TF-IDF.
3. Sistem menghitung tingkat kemiripan menggunakan Cosine Similarity.
4. Resep dengan tingkat kemiripan tertinggi akan ditampilkan sebagai rekomendasi.

---

## Environment Variable

Beberapa konfigurasi penting yang perlu disiapkan:

### Laravel `.env`

```env
APP_NAME=CookCash
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mongodb
DB_HOST=127.0.0.1
DB_PORT=27017
DB_DATABASE=cookcash_db
```

### Flask API `.env`

```env
GEMINI_API_KEY=
```

---

## Catatan Penggunaan

- Pastikan MongoDB sudah berjalan sebelum menjalankan Laravel.
- Pastikan server Laravel berjalan sebelum menjalankan aplikasi Flutter.
- Pastikan server Flask berjalan agar fitur chatbot dan rekomendasi dapat digunakan.
- Gunakan IP lokal komputer untuk menghubungkan Flutter dengan backend ketika memakai emulator atau perangkat Android.

---

## License

This code is distributed under an [MIT License](LICENSE).

---

## Copyright

Copyright (c) 2026 Kebon Almastrip Team
