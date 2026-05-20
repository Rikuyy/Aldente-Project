import json
import pandas as pd
import pickle
import os
import sys
import io
import re
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.metrics import classification_report, accuracy_score
from collections import Counter

# Opsional: Stemming (install Sastrawi dulu)
try:
    from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
    factory = StemmerFactory()
    stemmer = factory.create_stemmer()
    USE_STEMMING = True
except ImportError:
    USE_STEMMING = False
    print("⚠️ Sastrawi tidak terinstall, stemming di-skip", file=sys.stderr)

def run_evaluation():
    if sys.platform == 'win32':
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')
    
    try:
        # ---------- 1. PATH & LOAD ----------
        BASE_DIR = os.path.dirname(os.path.abspath(__file__))
        path_model = os.path.join(BASE_DIR, 'model_cookcash.pkl')
        path_csv   = os.path.join(BASE_DIR, 'Cookcash_Data_Test.csv')

        with open(path_model, 'rb') as f:
            model_data = pickle.load(f)
            
        if isinstance(model_data, tuple) and len(model_data) == 3:
            tfidf, tfidf_matrix, df_train = model_data
        elif isinstance(model_data, dict):
            tfidf = model_data.get('tfidf') or model_data.get('vectorizer')
            tfidf_matrix = model_data.get('tfidf_matrix') or model_data.get('matrix')
            df_train = model_data.get('df_train') or model_data.get('dataframe')

        # Baca CSV
        encodings_to_try = ['utf-8', 'latin1', 'iso-8859-1', 'cp1252']
        df_test = None
        for encoding in encodings_to_try:
            try:
                df_test = pd.read_csv(path_csv, encoding=encoding)
                break
            except (UnicodeDecodeError, UnicodeError):
                continue

        # ---------- 2. PARAMETER EVALUASI ----------
        K = 5  #  UBAH SESUAI KEBUTUHAN (1, 3, 5, 7)
        SIMILARITY_THRESHOLD = 0.25  #  Threshold minimal
        
        def clean_text(text):
            if not isinstance(text, str):
                text = str(text)
            text = re.sub(r'[^\x20-\x7E\x0A\x0D\u00A0-\u024F]', ' ', text)
            text = re.sub(r'\s+', ' ', text)
            text = text.strip().lower()
            
            # Stemming (kalau Sastrawi tersedia)
            if USE_STEMMING and len(text) > 3:
                try:
                    text = stemmer.stem(text)
                except:
                    pass
            return text

        # ---------- 3. PROSES EVALUASI ----------
        y_true = []
        y_pred = []
        detail_hasil = []
        
        for index, row in df_test.iterrows():
            query = clean_text(row['Ingredients Cleaned'])
            target_asli = clean_text(row['Category'])
            
            if not query or pd.isna(query):
                continue
                
            try:
                vec = tfidf.transform([query])
                sim = cosine_similarity(vec, tfidf_matrix).flatten()
                
                #  K-NN (bukan 1-NN)
                top_k_indices = sim.argsort()[-K:][::-1]
                top_k_categories = [clean_text(df_train['Category'].iloc[i]) 
                                   for i in top_k_indices]
                top_k_similarities = sim[top_k_indices]
                
                # Ambil similarity tertinggi
                best_similarity = top_k_similarities[0]
                
                # Voting
                category_votes = Counter(top_k_categories)
                prediksi_kategori = category_votes.most_common(1)[0][0]
                
                #  Threshold: kalau terlalu rendah, anggap "Tidak Diketahui"
                if best_similarity < SIMILARITY_THRESHOLD:
                    prediksi_kategori = "tidak diketahui"
                
                y_true.append(target_asli)
                y_pred.append(prediksi_kategori)
                
                detail_hasil.append({
                    "no": len(detail_hasil) + 1,
                    "soal": query[:100],
                    "target": target_asli,
                    "prediksi": prediksi_kategori,
                    "similarity": round(float(best_similarity) * 100, 2),
                    "status": "Benar" if prediksi_kategori == target_asli else "Salah"
                })
                
            except Exception as e:
                continue

        # ---------- 4. METRIK ----------
        akurasi = accuracy_score(y_true, y_pred) * 100
        report = classification_report(y_true, y_pred, output_dict=True, zero_division=0)
        
        benar = sum(1 for a, b in zip(y_true, y_pred) if a == b)
        salah = sum(1 for a, b in zip(y_true, y_pred) if a != b)

        output = {
            "status": "success",
            "konfigurasi": {
                "K_value": K,
                "similarity_threshold": SIMILARITY_THRESHOLD,
                "gunakan_stemming": USE_STEMMING
            },
            "ringkasan": {
                "akurasi": round(akurasi, 2),
                "total_data_diproses": len(y_true),
                "prediksi_benar": benar,
                "prediksi_salah": salah
            },
            "per_kategori": {
                kategori: {
                    "precision": round(metrics['precision'] * 100, 2),
                    "recall": round(metrics['recall'] * 100, 2),
                    "f1_score": round(metrics['f1-score'] * 100, 2),
                    "support": int(metrics['support'])
                }
                for kategori, metrics in report.items()
                if kategori not in ['accuracy', 'macro avg', 'weighted avg']
            },
            "detail_hasil": detail_hasil,
            "rekomendasi": [
                f" Gunakan K={K} (bukan K=1) untuk voting",
                " Tambah data latih kategori dengan F1 < 70%",
                " Coba ngram_range=(1,2) untuk tangkap bigram",
                "Jika akurasi masih < 75%, pertimbangkan metode lain (SVM/Random Forest)"
            ]
        }
        
        print(json.dumps(output, ensure_ascii=False, indent=2))

    except Exception as e:
        print(json.dumps({"status": "error", "message": str(e)}, ensure_ascii=False))

if __name__ == "__main__":
    run_evaluation()