import gradio as gr
import pandas as pd
import google.generativeai as genai
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# ==========================================
# 1. KONFIGURASI GEMINI API
# ==========================================
# MASUKKAN API KEY ANDA DI SINI
API_KEY = "AIzaSyDYr9ItDzOt6o0wR9n2Dn9Y67_6E--6rSM" 
genai.configure(api_key=API_KEY)

# Menggunakan gemini-pro yang paling stabil untuk teks
model = genai.GenerativeModel('gemini-pro')

# ==========================================
# 2. PERSIAPAN DATA (MENGGUNAKAN DATA TRAIN)
# ==========================================
print("Membaca data dari Data_Train.csv...")
try:
    df = pd.read_csv("Data_Train.csv", delimiter=";")
    
    # Mencegah error jika masih ada data kosong yang terselip
    df['Title Cleaned'] = df['Title Cleaned'].fillna("").astype(str)
    df['Ingredients Cleaned'] = df['Ingredients Cleaned'].fillna("").astype(str)

    # ALGORITMA TITLE BOOSTING: 
    # Judul digandakan 5x agar mesin lebih memprioritaskan nama masakan
    df['Search_Text'] = (df['Title Cleaned'] + " ") * 5 + df['Ingredients Cleaned']
except FileNotFoundError:
    print("ERROR: File Data_Train.csv tidak ditemukan. Pastikan Anda sudah menjalankan split_data.py!")
    df = pd.DataFrame()

def proses_chatbot(pesan_user, alergi_user):
    if df.empty:
        return "Database belum siap. Cek terminal untuk error.", pd.DataFrame()

    # TAHAP 1: FILTER ALERGI
    df_filtered = df.copy()
    if alergi_user:
        alergi = alergi_user.lower().strip()
        # Membuang resep yang bahan-bahannya mengandung kata alergi
        df_filtered = df_filtered[~df_filtered['Ingredients Cleaned'].str.contains(alergi, case=False, na=False)]
    
    if df_filtered.empty:
        return "Maaf, tidak ada resep yang aman dari alergi tersebut.", pd.DataFrame()

    # TAHAP 2: PENCARIAN KEMIRIPAN (TF-IDF + N-GRAM)
    vectorizer = TfidfVectorizer(ngram_range=(1, 2))
    tfidf_matrix = vectorizer.fit_transform(df_filtered['Search_Text'])
    
    user_vec = vectorizer.transform([pesan_user])
    scores = cosine_similarity(user_vec, tfidf_matrix).flatten()
    df_filtered['Similarity'] = scores
    
    # Ambil Top 3 resep dengan skor tertinggi
    top_3 = df_filtered.sort_values(by='Similarity', ascending=False).head(3)
    
    # Format Tabel Debug untuk Tampilan Web
    log_mesin = top_3[['Title', 'Similarity']].copy()
    log_mesin['Similarity'] = (log_mesin['Similarity'] * 100).round(2).astype(str) + " %"

    # Jika skor kemiripannya 0 (user ngetik sembarangan / di luar resep)
    if top_3['Similarity'].max() == 0:
        return "Resep yang kamu cari sepertinya belum ada di database aku nih. Coba menu yang lain ya!", log_mesin

    # TAHAP 3: MENYUSUN PROMPT UNTUK GEMINI
    konteks_resep = ""
    for index, row in top_3.iterrows():
        konteks_resep += f"Nama Resep: {row['Title']}\nBahan: {row['Ingredients']}\nLangkah: {row['Steps']}\n\n"

    prompt = f"""
    Kamu adalah asisten AI yang seru dan asik di aplikasi "Cookcash" (aplikasi khusus anak kos).
    User nanya/minta: "{pesan_user}"
    
    Tugasmu: Tawarkan 3 resep di bawah ini ke user dengan gaya bahasa anak kos yang santai. 
    JANGAN ngarang resep sendiri. HANYA rekomendasikan dari data ini:
    
    {konteks_resep}
    """
    
    try:
        response = model.generate_content(prompt)
        balasan_gemini = response.text
    except Exception as e:
        balasan_gemini = f"Waduh, error API Gemininya nih. Detail: {e}"

    return balasan_gemini, log_mesin

# ==========================================
# 3. ANTARMUKA WEB MENGGUNAKAN GRADIO
# ==========================================
with gr.Blocks() as web_ui:
    gr.Markdown("# 🍳 Prototype Chatbot Cookcash (Versi Final Data Train)")
    gr.Markdown("Algoritma Pencarian Cerdas (Title Boosting + N-Gram) dipadukan dengan Google Gemini.")
    
    with gr.Row():
        with gr.Column():
            input_pesan = gr.Textbox(label="User ngetik apa di Chatbot?", placeholder="Contoh: Pengen masakan ayam kecap dong")
            input_alergi = gr.Textbox(label="Data Alergi User (Kosongkan jika tidak ada)", placeholder="Contoh: kacang")
            tombol_kirim = gr.Button("Kirim 🚀", variant="primary")
            
        with gr.Column():
            output_chat = gr.Textbox(label="Balasan Chatbot Gemini", lines=10)
            output_debug = gr.Dataframe(label="Panel Debug: Skor Kemiripan Algoritma")

    tombol_kirim.click(fn=proses_chatbot, inputs=[input_pesan, input_alergi], outputs=[output_chat, output_debug])

if __name__ == "__main__":
    web_ui.launch(theme=gr.themes.Soft())