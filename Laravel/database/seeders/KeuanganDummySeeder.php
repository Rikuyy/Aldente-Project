<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Keuangan;
use Carbon\Carbon;

class KeuanganDummySeeder extends Seeder
{
    public function run(): void
    {
        // Pastikan isi Id_User sesuai dengan user yang ada di databasemu (contoh: 1)
        $userId = "6a108073b27279a5490bdbb2";

        // Kosongkan koleksi keuangan terlebih dahulu jika ingin datanya bersih
        Keuangan::where('Id_User', $userId)->delete();

        // Rentang waktu: 1 April 2026 s.d 28 Mei 2026
        $startDate = Carbon::create(2026, 4, 1);
        $endDate = Carbon::create(2026, 5, 28);

        $dataDummy = [];

        // Loop harian dari April sampai Mei
        while ($startDate->lte($endDate)) {
            $tanggalSign = $startDate->format('Y-m-d');
            $hariKe = $startDate->day;

            // 1. Logika Pemasukan Bulanan / Awal Bulan (Top Up / Budget awal)
            if ($hariKe === 1) {
                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => null,
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '08:00:00',
                    'Kategori' => 'Pemasukan',
                    'Keterangan' => 'Top Up',
                    'Detail' => [
                        ['item' => 'Alokasi Budget Awal Bulan', 'nominal' => 1500000]
                    ],
                    'Total_Nominal' => 1500000,
                    'created_at' => Carbon::parse("$tanggalSign 08:00:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 08:00:00"),
                ];
            }

            // 2. Transaksi Tengah Bulan (Contoh: Dani ganti uang di pertengahan April & Mei)
            if ($hariKe === 15) {
                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => null,
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '13:15:00',
                    'Kategori' => 'Pemasukan',
                    'Keterangan' => 'Top Up',
                    'Detail' => [
                        ['item' => 'Dani ganti uang futsal', 'nominal' => 34000]
                    ],
                    'Total_Nominal' => 34000,
                    'created_at' => Carbon::parse("$tanggalSign 13:15:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 13:15:00"),
                ];
            }

            // 3. Transaksi Rutin Pengeluaran Harian (Beli / Masak)
            // Hari Ganjil: Anggap saja user dominan Beli Makanan Luar
            if ($hariKe % 2 !== 0) {
                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => null,
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '12:30:00',
                    'Kategori' => 'Pengeluaran',
                    'Keterangan' => 'Beli',
                    'Detail' => [
                        ['item' => 'Nasi Pecel', 'nominal' => 13000],
                        ['item' => 'Kerupuk', 'nominal' => 2000]
                    ],
                    'Total_Nominal' => 15000, // Kalkulasi otomatis total nominal rincian di atas
                    'created_at' => Carbon::parse("$tanggalSign 12:30:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 12:30:00"),
                ];

                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => null,
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '19:00:00',
                    'Kategori' => 'Pengeluaran',
                    'Keterangan' => 'Lainnya',
                    'Detail' => [
                        ['item' => 'Beli Token Listrik Kos', 'nominal' => 50000]
                    ],
                    'Total_Nominal' => 50000,
                    'created_at' => Carbon::parse("$tanggalSign 19:00:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 19:00:00"),
                ];
            } 
            // Hari Genap: Anggap saja user rajin Masak sendiri
            else {
                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => 100 + $hariKe, // Angka dummy ID Jadwal Makan
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '07:15:00',
                    'Kategori' => 'Pengeluaran',
                    'Keterangan' => 'Masak',
                    'Detail' => [
                        ['item' => 'Bahan Ayam Kari India', 'nominal' => 20000]
                    ],
                    'Total_Nominal' => 20000,
                    'created_at' => Carbon::parse("$tanggalSign 07:15:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 07:15:00"),
                ];

                // Pengeluaran tambahan di sore hari
                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => null,
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '17:45:00',
                    'Kategori' => 'Pengeluaran',
                    'Keterangan' => 'Beli',
                    'Detail' => [
                        ['item' => 'Es Teh Manis Jumbo', 'nominal' => 5000],
                        ['item' => 'Gorengan', 'nominal' => 7000]
                    ],
                    'Total_Nominal' => 12000,
                    'created_at' => Carbon::parse("$tanggalSign 17:45:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 17:45:00"),
                ];
            }

            // 4. Kasus Khusus: Pengurangan/Penarikan Budget Bulanan (Misal tiap tanggal 25)
            if ($hariKe === 25) {
                $dataDummy[] = [
                    'Id_User' => $userId,
                    'Id_JadwalMakan' => null,
                    'Tanggal' => $tanggalSign,
                    'Waktu' => '10:00:00',
                    'Kategori' => 'Pengeluaran',
                    'Keterangan' => 'Pengurangan Budget',
                    'Detail' => [
                        ['item' => 'Tarik Tunai Mandiri ATM', 'nominal' => 200000]
                    ],
                    'Total_Nominal' => 200000,
                    'created_at' => Carbon::parse("$tanggalSign 10:00:00"),
                    'updated_at' => Carbon::parse("$tanggalSign 10:00:00"),
                ];
            }

            // Lanjut ke hari berikutnya
            $startDate->addDay();
        }

        // Mass insert ke MongoDB agar proses seeder cepat
        Keuangan::insert($dataDummy);

        $this->command->info('Data dummy keuangan dari 1 April - 28 Mei 2026 berhasil dibuat!');
    }
}