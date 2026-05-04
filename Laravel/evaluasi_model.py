import json
import pandas as pd
import pickle
import os
from sklearn.metrics.pairwise import cosine_similarity

try:
    # 1. Setup Path File
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    path_model = os.path.join(BASE_DIR, 'model_cookcash.pkl')
    path_csv = os.path.join(BASE_DIR, 'Cookcash_Data_Test.csv')
    
    # 2. Load Model AI
    with open(path_model, 'rb') as f:
        tfidf, tfidf_matrix, df_train = pickle.load(f)
        
    # 3. Baca Data Test dari CSV
    df_test = pd.read_csv(path_csv)
    
    benar = 0
    detail_hasil = []
    
    # 4. Mulai Ujian (Looping setiap baris)
    for index, row in df_test.iterrows():
        # Karena kolomnya persis dengan model, kita ambil Title dan Ingredients
        # Lalu digabung seperti saat proses training awal
        judul = str(row.get('Title Cleaned', ''))
        bahan = str(row.get('Ingredients Cleaned', ''))
        query_soal = (judul + " " + bahan).strip()
        
        # Target aslinya adalah kolom Category
        target_asli = str(row.get('Category', '')).lower().strip()
        
        # Proses AI menebak kemiripan teks
        query_vec = tfidf.transform([query_soal])
        sim = cosine_similarity(query_vec, tfidf_matrix).flatten()
        
        if len(sim) > 0 and sim.max() > 0:
            best_idx = sim.argmax()
            prediksi_kategori = str(df_train.iloc[best_idx].get('Category', '')).lower().strip()
        else:
            prediksi_kategori = "tidak ditemukan"
            
        # Cek apakah tebakan AI sama dengan target
        status = "Benar" if prediksi_kategori == target_asli else "Salah"
        if status == "Benar":
            benar += 1
            
        # Simpan hasil per baris
        detail_hasil.append({
            "soal": judul, # Di tabel web, kita tampilin judulnya aja biar gak kepanjangan
            "target": target_asli.upper(),
            "prediksi": prediksi_kategori.upper(),
            "status": status
        })
        
    # 5. Hitung Nilai Rapor
    akurasi = (benar / len(df_test)) * 100 if len(df_test) > 0 else 0
    
    output = {
        "status": "success",
        "akurasi": round(akurasi, 2),
        "total_uji": len(df_test),
        "prediksi_benar": benar,
        "detail_hasil": detail_hasil
    }
    
    # Print dalam bentuk JSON
    print(json.dumps(output))
    
except Exception as e:
    print(json.dumps({"status": "error", "message": str(e)}))