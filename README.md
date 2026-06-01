CookCash : Sistem Rekomendasi Resep dan Pencatatan Budget makan Berbasis Mobile Menggunakan Metode TF - IDF & Cosine Similarity Untuk Mahasiswa Indekos.  

Oleh    : Kebon Almastrip

Anggota :

•	Rifky Trio Saputra(E31240807/B) - [Ketua, Backend Mobile] - [@Rikuyy]

•	Ratna Dwiyati Ningsih(E31240813/B) - [Backend Web] - [@rnnaaa]

•	*Ovi Octa Rama Dhani(E31242213/D) - [Backend Mobile] - [@oviocta]

•	Muh. Rendi Kurniawan(E31240858/B) - [Frontend Mobile] - [@RerendiKurr05]

•	Nabil Zivkolin Danendra(E31240615/B) - [Frontend Web] - [@nabeeldndraa]

# Deskripsi
CookCash adalah aplikasi yang merekomendasikan resep berdasarkan input pengguna dan juga mengintegrasikan pencatatan pengeluaran pengguna. Secara keseluruhan, aplikasi ini berpusat pada Dashboard yang menampilkan ringkasan dompet beserta rekomendasi resep harian. Pengguna dapat berinteraksi melalui Consultation Page, yakni chatbot yang mengimplementasikan Gemini API dan backend Flask (menggunakan model TF-IDF dan Cosine Similarity) untuk mendapatkan saran resep yang spesifik. Di sisi finansial, fitur Keuangan mencatat riwayat pemasukan dan pengeluaran secara detail yang divisualisasikan ke dalam grafik. Selain itu, terdapat fitur Inventory/Stok untuk mencatat ketersediaan bahan makanan secara manual, serta To-Do List (Cook) sebagai jadwal memasak, di mana menunya dapat diatur dan diganti langsung melalui halaman konsultasi maupun rekomendasi dashboard.

# Fitur Utama
1.	Dashboard Cerdas
Menampilkan ringkasan saldo/dompet pengguna dan rekomendasi resep harian.
2.	Consultation Page (Chatbot)
 Asisten Cookcash yang merekomendasikan resep masakan berdasarkan input bahan atau keinginan pengguna. Didukung oleh integrasi Gemini API dan model Machine Learning (TF-IDF & Cosine Similarity).
3.	Manajemen Keuangan 
Pencatatan pemasukan dan pengeluaran secara detail, dilengkapi dengan grafik visualisasi arus kas.
4.	Inventory / Stok Bahan
Fitur pencatatan daftar stok bahan makanan yang dimiliki pengguna secara manual.
5.	To-Do List (Cook Schedule) 
Jadwal memasak terencana. Menu dapat ditambahkan atau diubah langsung melalui halaman konsultasi (Chatbot) atau rekomendasi di Dashboard.

#  Arsitektur & Teknologi (Tech Stack)
•	Mobile/Android : Flutter
•	Backend API & Web : PHP (Laravel)
•	Database : MongoDB
•	Machine Learning API: Python (Flask), Scikit-Learn (TF-IDF, Cosine Similarity)
•	Third-Party API: Google Gemini API

# Persiapan & Prasyarat Sistem
Sebelum menginstal proyek ini, pastikan sistem Anda sudah terinstal perangkat lunak berikut:
•	[Git](https://git-scm.com/ )
•	[PHP 8.2](https://www.php.net/ ) & [Composer](https://getcomposer.org/ )
•	[Flutter SDK](https://docs.flutter.dev/get-started/install )
•	[Python 3.9+](https://www.python.org/ ) & `pip`
•	[MongoDB](https://www.mongodb.com/ ) (Lokal atau MongoDB Atlas)
•	Mendapatkan API Key dari [Google AI Studio (Gemini)](https://aistudio.google.com/ )

# Langkah - Langkah  Instalasi (Cara Replika Proyek)
Ikuti langkah-langkah di bawah ini secara berurutan untuk menjalankan proyek CookCash di perangkat lokal Anda.
1.	Clone Repositori
Buka terminal/command prompt dan jalankan perintah berikut:
git clone https://github.com/Rikuyy/Aldente-Project 
cd CookCash
(Catatan: Repositori ini menggunakan struktur monorepo yang berisi folder backend-laravel, ml-flask, dan mobile-flutter).
2.	Konfigurasi Database (MongoDB)
1)	Pastikan service MongoDB sudah berjalan di komputer Anda.
2)	Buat database baru dengan nama cookcash_db (bisa menggunakan MongoDB Compass).
3.	Setup Backend & Web (Laravel)
1)	Masuk ke direktori backend: 
cd Laravel
2)	Instal dependensi PHP : 

composer install

3)	Salin file environment dan sesuaikan koneksi database MongoDB:
cp .env.example .env

Buka file .env dan atur konfigurasi database:

Cuplikan kode 
DB_CONNECTION=mongodb
DB_HOST=127.0.0.1
DB_PORT=27017
DB_DATABASE=cookcash_db

4)	Kemudian  jalankan server:
php artisan serve
(Backend akan berjalan di http://localhost:8000)

4. Setup API Machine Learning & Chatbot (Flask)
1)	Buka terminal baru dan masuk ke direktori Flask:
cd API
2)	Buat virtual environment dan aktifkan:
python -m venv venv
# Untuk Windows:
venv\Scripts\activate
# Untuk Mac/Linux:
source venv/bin/activate
3)	Instal dependensi Python:
pip install -r requirements.txt
4)	Konfigurasi Gemini API: Buat file .env di dalam folder ml-flask dan tambahkan API Key Anda:
Cuplikan kode
GEMINI_API_KEY=masukkan_api_key_anda_di_sini
5)	Jalankan server Flask:
python app.py
(API ML akan berjalan di http://localhost:5000)

5. Setup Mobile App (Flutter)
1)	Buka terminal baru dan masuk ke direktori aplikasi mobile:
cd Flutter
2)	Ambil dependensi Flutter:
flutter pub get
3)	Sesuaikan Base URL API di dalam kode Flutter. Buka file konfigurasi API (CookCash\Flutter\lib\services\api_service.dart) dan pastikan mengarah ke IP lokal komputer Anda (bukan localhost, gunakan IPv4 contoh: 192.168.1.x).
4)	Jalankan aplikasi di emulator atau perangkat fisik Android:
flutter run





MIT License

Copyright (c) 2026 Kebon Almastrip Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
