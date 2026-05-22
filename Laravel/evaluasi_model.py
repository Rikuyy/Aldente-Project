import json
import pandas as pd
import pickle
import os
import sys
from sklearn.metrics.pairwise import cosine_similarity

def run_evaluation():
    try:
        # 1. Setup Path File secara Dinamis
        # Menggunakan lokasi script sebagai titik acuan agar tidak error saat dipanggil Laravel
        BASE_DIR = os.path.dirname(os.path.abspath(__file__))
        path_model = os.path.join(BASE_DIR, 'model_cookcash.pkl')
        path_csv = os.path.join(BASE_DIR, 'Cookcash_Data_Test.csv')
        
        # Cek apakah file model dan data test ada
        if not os.path.exists(path_model):
            raise FileNotFoundError(f"Model pkl tidak ditemukan di: {path_model}")
        if not os.path.exists(path_csv):
            raise FileNotFoundError(f"File CSV data test tidak ditemukan di: {path_csv}")

        # 2. Load Model AI
        # tfidf: Kamus kata, tfidf_matrix: Vektor database resep, df_train: Data mentah resep
        with open(path_model, 'rb') as f:
            tfidf, tfidf_matrix, df_train = pickle.load(f)
            
        # 3. Baca Data Test
        df_test = pd.read_csv(path_csv)
        
        # Validasi kolom CSV
        required_cols = ['Title Cleaned', 'Ingredients Cleaned', 'Category']
        for col in required_cols:
            if col not in df_test.columns:
                raise ValueError(f"Kolom '{col}' tidak ditemukan dalam CSV data test.")

        benar = 0
        detail_hasil = []
        
        # 4. Proses Evaluasi (Looping Data Test)
        for index, row in df_test.iterrows():
            # PENTING: Penggabungan teks harus SAMA dengan skrip training (Title + Ingredients)
            judul = str(row['Title Cleaned']).strip()
            bahan = str(row['Ingredients Cleaned']).strip()
            query_soal = f"{judul} {bahan}"
            
            # Label asli (target)
            target_asli = str(row['Category']).lower().strip()
            
            # AI Menebak: Ubah teks soal jadi vektor, lalu hitung kemiripan dengan database
            query_vec = tfidf.transform([query_soal])
            sim = cosine_similarity(query_vec, tfidf_matrix).flatten()
            
            # Cari indeks dengan nilai kemiripan (similarity) tertinggi
            if len(sim) > 0 and sim.max() > 0:
                best_idx = sim.argmax()
                # Ambil kategori dari database training berdasarkan hasil paling mirip
                prediksi_kategori = str(df_train.iloc[best_idx].get('Category', '')).lower().strip()
                skor_kemiripan = f"{sim.max() * 100:.1f}%"
            else:
                prediksi_kategori = "tidak ditemukan"
                skor_kemiripan = "0%"
                
            # Cek akurasi tebakan
            status = "Benar" if prediksi_kategori == target_asli else "Salah"
            if status == "Benar":
                benar += 1
                
            # Simpan detail untuk tabel di Laravel
            detail_hasil.append({
                "soal": judul,
                "target": target_asli.upper(),
                "prediksi": prediksi_kategori.upper(),
                "kemiripan": skor_kemiripan,
                "status": status
            })
            
        # 5. Hitung Skor Akhir
        total_data = len(df_test)
        akurasi = (benar / total_data) * 100 if total_data > 0 else 0
        
        # Format Output untuk Laravel
        output = {
            "status": "success",
            "akurasi": round(akurasi, 2),
            "total_uji": total_data,
            "prediksi_benar": benar,
            "detail_hasil": detail_hasil
        }
        
        # Kirimkan hasil ke stdout sebagai JSON
        print(json.dumps(output))

    except Exception as e:
        # Jika ada error (misal: Pandas error atau Pickle error)
        error_output = {
            "status": "error",
            "message": str(e)
        }
        print(json.dumps(error_output))

if __name__ == "__main__":
    run_evaluation()