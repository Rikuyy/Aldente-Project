from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle

app = Flask(__name__)

# Mengaktifkan CORS agar Flutter Web (Edge) tidak diblokir
CORS(app)

# Memuat model machine learning kamu
# Pastikan file model.pkl berada di folder yang sama dengan app.py
try:
    with open('model.pkl', 'rb') as file:
        model = pickle.load(file)
except Exception as e:
    print(f"Gagal memuat model: {e}")
    model = None

@app.route('/api', methods=['POST'])
def chat_bot():
    # Menerima data JSON dari aplikasi Flutter kamu
    data = request.json
    pesan_user = data.get('message', '')
    
    if model is None:
        return jsonify({"reply": "Maaf, sistem rekomendasi (model) sedang tidak aktif."}), 500

    # --- DI SINI LOGIKA PREDIKSI MODELMU ---
    # Contoh ilustrasi: 
    # hasil_prediksi = model.predict([pesan_user])
    # rekomendasi = hasil_prediksi[0]
    
    # Karena kita belum tau bentuk modelmu, kita pakai balasan dummy dulu
    rekomendasi = f"Model menerima input: {pesan_user}. Ini rekomendasi resepnya!"

    # Mengembalikan balasan ke Flutter
    return jsonify({"reply": rekomendasi})

if __name__ == '__main__':
    # host='0.0.0.0' SANGAT PENTING agar API bisa diakses oleh Emulator & HP fisik via Wi-Fi
    app.run(host='0.0.0.0', port=8000, debug=True)