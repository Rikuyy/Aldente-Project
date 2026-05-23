import pandas as pd
import pickle
import os
from pymongo import MongoClient
from sklearn.feature_extraction.text import TfidfVectorizer

try:
    client = MongoClient('mongodb://localhost:27017/')
    db = client['cookcash_db']
    collection = db['resep']

    df_train = pd.DataFrame(list(collection.find()))
    if '_id' in df_train.columns:
        df_train.drop(columns=['_id'], inplace=True)

    df_train['Teks_Gabungan'] = df_train['Title Cleaned'].astype(str) + " " + df_train['Ingredients Cleaned'].astype(str)
    df_train['Teks_Gabungan'] = df_train['Teks_Gabungan'].fillna('')

    tfidf = TfidfVectorizer()
    tfidf_matrix = tfidf.fit_transform(df_train['Teks_Gabungan'])

    # CARA DINAMIS: Simpan di folder yang sama dengan script ini
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    path_model = os.path.join(BASE_DIR, 'model_cookcash.pkl')
    
    with open(path_model, 'wb') as f:
        pickle.dump((tfidf, tfidf_matrix, df_train), f)

    print("Success")
except Exception as e:
    print(f"Error: {str(e)}")