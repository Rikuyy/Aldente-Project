import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        title: const Text('Laporan Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.slate800, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.slate100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('TOTAL PENGELUARAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.slate500)),
                        SizedBox(height: 8),
                        Text('Rp240.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.slate800)),
                        SizedBox(height: 4),
                        Text('+15% dari minggu lalu', style: TextStyle(fontSize: 11, color: AppTheme.red500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.slate100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('RATA-RATA/HARI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.slate500)),
                        SizedBox(height: 8),
                        Text('Rp34.285', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.slate800)),
                        SizedBox(height: 4),
                        Text('Lebih hemat Rp5rb', style: TextStyle(fontSize: 11, color: AppTheme.green500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.orange50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.orange200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.error_outline_rounded, color: AppTheme.orange600, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prediksi Akhir Bulan: Defisit', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF431407), fontSize: 13)),
                        SizedBox(height: 4),
                        Text(
                          'Dengan pengeluaran saat ini, diprediksi total pengeluaran akhir bulan mencapai Rp1.028.000.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF9A3412), fontWeight: FontWeight.w500, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Komposisi Pengeluaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.slate800)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.slate100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.orange50,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.orange200, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              '62%',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.slate800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.orange500, shape: BoxShape.circle)),
                            SizedBox(width: 8),
                            Text('Masak Sendiri', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Rp150.000', style: TextStyle(fontSize: 11, color: AppTheme.slate500)),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: DecoratedBox(decoration: BoxDecoration(color: AppTheme.slate200)),
                            ),
                            SizedBox(width: 8),
                            Text('Jajan Luar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Rp90.000', style: TextStyle(fontSize: 11, color: AppTheme.slate500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
