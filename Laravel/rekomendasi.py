import pickle
import sys
import json
import os
from sklearn.metrics.pairwise import cosine_similarity

def main():
    if len(sys.argv) < 2:
        print(json.dumps([]))
        return

    query = sys.argv[1]
    
    # Ambil data alergi dari Laravel (kalau ada)
    alergi_input = ""
    if len(sys.argv) >= 3:
        alergi_input = sys.argv[2].lower()
        
    # Pecah alergi jadi list (misal: "kacang, udang" -> ['kacang', 'udang'])
    list_alergi = [a.strip() for a in alergi_input.split(',')] if alergi_input else []

    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    path_model = os.path.join(BASE_DIR, 'model_cookcash.pkl')

    try:
        with open(path_model, 'rb') as f:
            tfidf, tfidf_matrix, df_train = pickle.load(f)

        vec = tfidf.transform([query])
        sim = cosine_similarity(vec, tfidf_matrix).flatten()
        
        # Urutkan SEMUA dari yang paling mirip
        sorted_indices = sim.argsort()[::-1]
        
        hasil = []
        for idx in sorted_indices:
            if sim[idx] > 0:
                # Ambil bahan dari DataFrame
                bahan = str(df_train['Ingredients Cleaned'].iloc[idx]).lower()
                
                # --- SISTEM FILTER ALERGI PINTAR ---
                aman = True
                for alergi in list_alergi:
                    if alergi != "" and alergi in bahan:
                        aman = False # Bahaya! Ada bahan alergi
                        break
                        
                # Kalau aman, baru masukkan ke hasil akhir
                if aman:
                    hasil.append({
                        "title": str(df_train['Title Cleaned'].iloc[idx]),
                        "category": str(df_train['Category'].iloc[idx]),
                        "ingredients": str(df_train['Ingredients Cleaned'].iloc[idx]),
                        "steps": str(df_train['Steps'].iloc[idx]),
                        "similarity": f"{sim[idx] * 100:.0f}%"
                    })
                    
            # Kalau udah dapet 5 resep yang AMAN, langsung berhenti mencari
            if len(hasil) == 5:
                break
                
        print(json.dumps(hasil))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()