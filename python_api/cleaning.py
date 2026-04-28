import pandas as pd

def clean_dataset(input_file, output_file):
    print("Memulai proses pembacaan dan cleaning data (VERSI KETAT)...")
    try:
        df = pd.read_csv(input_file, delimiter=';')
    except FileNotFoundError:
        print(f"Error: File {input_file} tidak ditemukan.")
        return None
    
    print(f"Total baris awal sebelum cleaning: {len(df)}")
    
    # 1. HAPUS SEMUA BARIS YANG KOSONG (NULL/NaN) DI KOLOM-KOLOM KRUSIAL
    kolom_krusial = ['Title', 'Title Cleaned', 'Ingredients', 'Ingredients Cleaned', 'Steps', 'Category']
    df = df.dropna(subset=kolom_krusial)
    
    # 2. BASMI STRING "nan" ATAU BARIS YANG CUMA SPASI
    for col in kolom_krusial:
        # Ubah jadi string dan hapus spasi kiri-kanan
        df[col] = df[col].astype(str).str.strip()
        # Buang baris yang setelah dihapus spasinya ternyata jadi kosong ("")
        df = df[df[col] != ""]
        # Buang baris yang isinya teks "nan" atau "null" (error ketikan)
        df = df[~df[col].str.lower().isin(['nan', 'null'])]
        
    # 3. PERBAIKAN KOLOM 'Loves' (Untuk Dashboard)
    df['Loves'] = pd.to_numeric(df['Loves'], errors='coerce').fillna(0).astype(int)
    
    # 4. NORMALISASI TEKS (HURUF KECIL SEMUA)
    df['Category'] = df['Category'].str.lower()
    df['Ingredients Cleaned'] = df['Ingredients Cleaned'].str.lower()
    df['Title Cleaned'] = df['Title Cleaned'].str.lower()
    
    # 5. Simpan dataset yang benar-benar 100% padat dan bersih
    df.to_csv(output_file, sep=';', index=False)
    
    print(f"Total baris akhir setelah semua data rusak dibuang: {len(df)}")
    print(f"BERHASIL! Data SUPER BERSIH siap pakai disimpan sebagai: {output_file}\n")
    return df

# ==========================================
# FUNGSI-FUNGSI PENDUKUNG SISTEM COOKCASH
# ==========================================

def filter_alergi(df, alergi_user):
    if not alergi_user:
        return df 
    alergi = alergi_user.lower().strip()
    df_aman = df[~df['Ingredients Cleaned'].str.contains(alergi, case=False, na=False)]
    return df_aman

def get_dashboard_recommendation(df, kategori_user, top_n=6):
    kategori = kategori_user.lower().strip()
    df_kategori = df[df['Category'] == kategori]
    df_top = df_kategori.sort_values(by='Loves', ascending=False).head(top_n)
    return df_top[['Title', 'Ingredients', 'Steps', 'Loves', 'Total Ingredients', 'Category']]


if __name__ == "__main__":
    FILE_AWAL = 'Book5.csv'
    FILE_BARU = 'Cookcash_Dataset_Ready.csv'
    
    dataset_bersih = clean_dataset(FILE_AWAL, FILE_BARU)
    
    if dataset_bersih is not None:
        kategori_unik = dataset_bersih['Category'].unique()
        print("=====================================================")
        print("DAFTAR KATEGORI UNTUK FORM APLIKASI MOBILE (FLUTTER):")
        print(f"Nama Kategori  : {list(kategori_unik)}")
        print("=====================================================\n")