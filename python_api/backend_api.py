from flask import Flask, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
from sklearn.metrics.pairwise import cosine_similarity

# Bikin jembatan API-nya
app = Flask(__name__)
CORS(app) # Ini wajib biar web Laravel temanmu nggak diblokir pas minta data

print("Memanaskan Mesin AI...")
# Buka otak AI (Hanya dilakukan 1x pas server dinyalakan)
try:
    vectorizer = joblib.load("vectorizer_cookcash.pkl")
    tfidf_matrix = joblib.load("matrix_cookcash.pkl")
    df_train = pd.read_pickle("data_resep.pkl")
    df_test = pd.read_csv("Data_Test.csv", delimiter=";")
    print("Mesin AI Siap Melayani!")
except Exception as e:
    print(f"Waduh, ada error baca data: {e}")

# ==========================================
# RUTE API UNTUK HALAMAN TESTING
# Web temanmu akan ngetok pintu ke URL: http://127.0.0.1:5000/api/ujian
# ==========================================
@app.route('/api/ujian', methods=['GET'])
def api_ujian():
    try:
        # Ambil 50 soal acak
        df_sample = df_test.sample(min(50, len(df_test)), random_state=42)
        
        hasil_ujian = []
        benar = 0
        
        for _, row in df_sample.iterrows():
            query = str(row['Title Cleaned'])
            ground_truth = row['Category']
            
            # AI Mikir
            vec = vectorizer.transform([query])
            sim = cosine_similarity(vec, tfidf_matrix).flatten()
            
            idx = sim.argmax()
            pred_title = df_train.iloc[idx]['Title']
            pred_cat = df_train.iloc[idx]['Category']
            score = round(sim[idx] * 100, 2)
            
            if ground_truth == pred_cat:
                status = "Sesuai"
                benar += 1
            else:
                status = "Tidak Sesuai"
                
            # Masukin jawaban ke dalam list
            hasil_ujian.append({
                "soal": query,
                "kunci_jawaban": ground_truth,
                "tebakan_ai": pred_title,
                "kategori_tebakan": pred_cat,
                "skor_kemiripan": score,
                "status": status
            })
            
        akurasi = round((benar / len(df_sample)) * 100, 2)
        
        # BUNGKUS KE DALAM "KOTAK BEKAL" (JSON)
        kotak_bekal = {
            "pesan": "Ujian Berhasil Diselesaikan",
            "total_soal": len(df_sample),
            "total_benar": benar,
            "akurasi": akurasi,
            "detail_jawaban": hasil_ujian
        }
        
        # Kirim kotak bekal ke Laravel temanmu
        return jsonify(kotak_bekal)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Nyalakan servernya!
if __name__ == '__main__':
    app.run(debug=True, port=5000)