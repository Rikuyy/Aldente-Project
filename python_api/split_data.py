import pandas as pd
from sklearn.model_selection import train_test_split

def bagi_data():
    print("Membaca file Cookcash_Dataset_Ready.csv...")
    try:
        df = pd.read_csv("Cookcash_Dataset_Ready.csv", delimiter=";")
    except FileNotFoundError:
        print("Error: File dataset tidak ditemukan. Pastikan sudah menjalankan cleaning.py!")
        return
    
    # Membagi data menjadi 80% Train dan 20% Test
    # stratify=df['Category'] memastikan setiap kategori dibagi sama rata proporsinya
    # random_state=42 memastikan pembagian datanya konsisten/tidak berubah-ubah kalau di-run ulang
    print("Membagi data dengan proporsi 80% Train dan 20% Test (Stratified)...")
    train_df, test_df = train_test_split(df, test_size=0.20, random_state=42, stratify=df['Category'])
    
    # Menyimpan file hasil pembagian
    train_df.to_csv("Data_Train.csv", sep=";", index=False)
    test_df.to_csv("Data_Test.csv", sep=";", index=False)
    
    # Menampilkan Laporan untuk Anda catat di Buku Skripsi/Laporan
    print("\n=================================================")
    print("✅ PEMBAGIAN DATA BERHASIL!")
    print("=================================================")
    print(f"Total Seluruh Data   : {len(df)} resep")
    print(f"Total Data Train 80% : {len(train_df)} resep (Disimpan di 'Data_Train.csv')")
    print(f"Total Data Test  20% : {len(test_df)} resep (Disimpan di 'Data_Test.csv')")
    print("=================================================\n")

if __name__ == "__main__":
    bagi_data()