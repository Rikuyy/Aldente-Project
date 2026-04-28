import pandas as pd
import joblib 
from sklearn.feature_extraction.text import TfidfVectorizer

def bikin_pkl():
    print("AI sedang membaca buku Data_Train.csv...")
    # Baca data latihannya
    df = pd.read_csv("Data_Train.csv", delimiter=";")
    
    # Rapihin teksnya
    df['Title Cleaned'] = df['Title Cleaned'].fillna("").astype(str)
    df['Ingredients Cleaned'] = df['Ingredients Cleaned'].fillna("").astype(str)
    
    # Gabungin judul (dikali 5 biar penting) dan bahan
    teks_belajar = (df['Title Cleaned'] + " ") * 5 + df['Ingredients Cleaned']

    # 1. Bikin Mesin Pencarinya (Vectorizer)
    print("AI sedang menghitung kata-kata...")
    vectorizer = TfidfVectorizer(ngram_range=(1, 2))
    
    # 2. Mesin mulai merangkum data (Fit & Transform)
    tfidf_matrix = vectorizer.fit_transform(teks_belajar)
    
    # 3. SIMPAN HASIL BELAJAR JADI FILE .PKL
    print("Sedang menyimpan hasil belajar ke file .pkl...")
    joblib.dump(vectorizer, "vectorizer_cookcash.pkl")
    joblib.dump(tfidf_matrix, "matrix_cookcash.pkl")
    df.to_pickle("data_resep.pkl")

    print("✅ SELESAI! AI sudah pintar dan file .pkl berhasil dibuat!")

if __name__ == "__main__":
    bikin_pkl()