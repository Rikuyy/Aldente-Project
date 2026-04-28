import gradio as gr
import pandas as pd
import joblib
from sklearn.metrics.pairwise import cosine_similarity

def evaluasi_sistem():
    try:
        # Load Model & Data
        vectorizer = joblib.load("vectorizer_cookcash.pkl")
        tfidf_matrix = joblib.load("matrix_cookcash.pkl")
        df_train = pd.read_pickle("data_resep.pkl")
        df_test = pd.read_csv("Data_Test.csv", delimiter=";")
        
        # Ambil sampel 50 data uji (unseen data)
        df_sample = df_test.sample(min(50, len(df_test)), random_state=42)
        
        results = []
        benar = 0
        
        for _, row in df_sample.iterrows():
            query = str(row['Title Cleaned'])
            ground_truth = row['Category']
            
            # Hitung Similarity
            vec = vectorizer.transform([query])
            sim = cosine_similarity(vec, tfidf_matrix).flatten()
            
            # Ambil Top 1
            idx = sim.argmax()
            pred_title = df_train.iloc[idx]['Title']
            pred_cat = df_train.iloc[idx]['Category']
            score = sim[idx]
            
            is_correct = "SESUAI" if ground_truth == pred_cat else "TIDAK SESUAI"
            if ground_truth == pred_cat: benar += 1
            
            results.append([query, ground_truth, pred_title, pred_cat, f"{score*100:.2f}%", is_correct])
            
        akurasi = (benar / len(df_sample)) * 100
        
        # Output Rapor Nilai
        summary = f"""
        ## 📊 Laporan Evaluasi Performa Algoritma
        ---
        * **Metode:** TF-IDF dengan Cosine Similarity
        * **Total Data Uji (Unseen):** {len(df_sample)} Resep
        * **Prediksi Kategori Benar:** {benar}
        * **Rata-rata Akurasi Sistem:** {akurasi:.2f}%
        """
        
        df_final = pd.DataFrame(results, columns=["Input Query", "Kategori Target", "Rekomendasi Teratas", "Kategori Prediksi", "Confidence Score", "Status"])
        return summary, df_final

    except Exception as e:
        return f"### ❌ Terjadi Kesalahan: {e}", pd.DataFrame()

# ==========================================
# UI DESIGN (PRO VERSION)
# ==========================================
with gr.Blocks(theme=gr.themes.Soft()) as app:
    gr.HTML("<div style='text-align: center;'><h1>🛠️ Dashboard Admin & Evaluasi Algoritma</h1><p>Sistem Rekomendasi Resep Anak Kos - Cookcash Project</p></div>")
    
    with gr.Row():
        with gr.Column(scale=1):
            gr.Markdown("### Kontrol Pengujian")
            gr.Markdown("Klik tombol di bawah untuk menjalankan pengujian otomatis terhadap Data_Test.csv.")
            btn = gr.Button("Jalankan Uji Akurasi", variant="primary")
            
        with gr.Column(scale=3):
            output_summary = gr.Markdown("Menunggu input...")
            
    gr.Markdown("### 📄 Tabel Detail Hasil Retrieval")
    output_table = gr.Dataframe(interactive=False)

    btn.click(evaluasi_sistem, outputs=[output_summary, output_table])

if __name__ == "__main__":
    app.launch()