import json
import pandas as pd
import pickle
import os
import sys
import io
import re
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

# Optional stemming
try:
    from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
    factory = StemmerFactory()
    stemmer = factory.create_stemmer()
    USE_STEMMING = True
except ImportError:
    USE_STEMMING = False

def clean_text(text):
    if not isinstance(text, str):
        text = str(text)
    text = re.sub(r'[^\x20-\x7E\x0A\x0D\u00A0-\u024F]', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    text = text.strip().lower()
    if USE_STEMMING and len(text) > 3:
        try:
            text = stemmer.stem(text)
        except:
            pass
    return text

def run_evaluation():
    # UTF-8 handling for Windows
    if sys.platform == 'win32':
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

    try:
        BASE_DIR = os.path.dirname(os.path.abspath(__file__))
        path_model = os.path.join(BASE_DIR, 'model_cookcash.pkl')
        path_csv   = os.path.join(BASE_DIR, 'Cookcash_Data_Test.csv')

        # Load model
        with open(path_model, 'rb') as f:
            model_data = pickle.load(f)

        if isinstance(model_data, tuple) and len(model_data) == 3:
            tfidf, tfidf_matrix, df_train = model_data
        else:
            tfidf = model_data.get('tfidf')
            tfidf_matrix = model_data.get('tfidf_matrix')
            df_train = model_data.get('df_train')

        # Load test data
        encodings = ['utf-8', 'latin1', 'iso-8859-1', 'cp1252']
        df_test = None
        for enc in encodings:
            try:
                df_test = pd.read_csv(path_csv, encoding=enc)
                break
            except:
                continue
        if df_test is None:
            raise Exception("Tidak dapat membaca file CSV test")

        # Parameters (mengikuti hasil Grid Search terbaik)
        K = 10
        THRESHOLD = 0.4

        precision_scores = []
        recall_scores = []
        detail_hasil = []

        for idx, row in df_test.iterrows():
            query = clean_text(row['Ingredients Cleaned'])
            if not query:
                continue

            # Vektor query dan similarity
            vec = tfidf.transform([query])
            sim = cosine_similarity(vec, tfidf_matrix).flatten()
            top_k_idx = sim.argsort()[-K:][::-1]
            top_k_sim = sim[top_k_idx]

            # --- Precision@K dan Recall@K berdasarkan threshold similarity ---
            relevan = sum(top_k_sim >= THRESHOLD)
            total_relevan = sum(sim >= THRESHOLD)
            precision = relevan / K
            recall = relevan / total_relevan if total_relevan > 0 else 0
            precision_scores.append(precision)
            recall_scores.append(recall)

            # --- AMBIL RESEP TERATAS UNTUK DITAMPILKAN DI TABEL ---
            top_recipe_title = df_train.iloc[top_k_idx[0]]['Title Cleaned']
            max_sim = top_k_sim[0]
            
            # Status Relevan jika skor kemiripan memenuhi KKM (Threshold)
            status_rekomendasi = "Relevan" if max_sim >= THRESHOLD else "Tidak Relevan"

            detail_hasil.append({
                "no": len(detail_hasil) + 1,
                "soal": query[:100],
                "rekomendasi": top_recipe_title,
                "similarity": round(max_sim * 100, 2),
                "status": status_rekomendasi
            })

        # Rata-rata precision dan recall
        avg_precision = np.mean(precision_scores) * 100
        avg_recall = np.mean(recall_scores) * 100

        # Siapkan output JSON (Fokus Murni Rekomendasi)
        output = {
            "status": "success",
            "konfigurasi": {
                "K_value": K,
                "similarity_threshold": THRESHOLD,
                "gunakan_stemming": USE_STEMMING,
                "metrik": "Precision@K dan Recall@K (berdasarkan threshold cosine similarity)"
            },
            "ringkasan": {
                "akurasi": round(avg_precision, 2),
                "recall": round(avg_recall, 2),
                "total_data_diproses": len(detail_hasil)
            },
            "detail_hasil": detail_hasil,
            "rekomendasi": [
                f"📊 Precision@{K}: {avg_precision:.2f}% | Recall@{K}: {avg_recall:.2f}% (threshold={THRESHOLD})",
                "✅ Fokus murni pada hasil rekomendasi Content-Based Filtering."
            ]
        }

        print(json.dumps(output, ensure_ascii=False, indent=2))

    except Exception as e:
        print(json.dumps({"status": "error", "message": str(e)}, ensure_ascii=False))

if __name__ == "__main__":
    run_evaluation()