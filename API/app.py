import pickle
import logging
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from sklearn.metrics.pairwise import cosine_similarity

# ---------------------------------------------------------------------------
# Inisialisasi Aplikasi
# ---------------------------------------------------------------------------
app = Flask(__name__)
CORS(app)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__) 
tfidf = None
tfidf_matrix = None
df_recipes = None

try:
    with open("model_cookcash.pkl", "rb") as f:
        tfidf, tfidf_matrix, df_recipes = pickle.load(f)
    logger.info(f"Model berhasil dimuat. Total resep: {len(df_recipes)}")
except FileNotFoundError:
    logger.warning("File model_cookcash.pkl tidak ditemukan.")
except Exception as e:
    logger.error(f"Gagal memuat model : {e}")


# ---------------------------------------------------------------------------
# Fungsi Rekomendasi
# ---------------------------------------------------------------------------
def get_recommendations(query: str, top_n: int = 5) -> list:
    query_vec = tfidf.transform([query])
    scores = cosine_similarity(query_vec, tfidf_matrix).flatten()
    top_indices = scores.argsort()[::-1][:top_n]

    results = []
    for idx in top_indices:
        row = df_recipes.iloc[idx]
        raw_steps = str(row.get("Steps", ""))
        steps_list = [
            s.strip()
            for s in raw_steps.replace("\\n", "\n").split("\n")
            if s.strip()
        ]
        results.append({
            "title":             row["Title Cleaned"],
            "ingredients":       row["Ingredients Cleaned"],
            "steps":             steps_list,
            "total_steps":       int(row.get("Total Steps", len(steps_list))),
            "total_ingredients": int(row.get("Total Ingredients", 0)),
            "loves":             int(row.get("Loves", 0)),
            "category":          row["Category"],
            "score":             round(float(scores[idx]), 4),
        })
    return results


# ---------------------------------------------------------------------------
# Endpoint Rekomendasi
# ---------------------------------------------------------------------------
@app.route("/api", methods=["POST"])
def recommend():
    data = request.get_json(force=True, silent=True)

    if not data:
        return jsonify({
            "success": False,
            "reply": "Data JSON tidak valid atau kosong.",
        }), 400

    title = str(data.get("Title_Cleaned", "")).strip()
    ingredients = data.get("Ingredients_Cleaned", [])
    category = str(data.get("Category", "")).strip()

    if isinstance(ingredients, str):
        ingredients = [i.strip() for i in ingredients.split(",") if i.strip()]

    # Bangun query tunggal untuk model
    ingredients_str = " ".join(ingredients).strip()
    query_model = " ".join(filter(None, [title, ingredients_str, category])).strip()

    logger.info(f"Query model: '{query_model}'")

    # Validasi query tidak kosong
    if not query_model:
        return jsonify({
            "success": False,
            "reply": (
                "Hei, sepertinya kamu belum memasukkan detail bahan atau nama masakan. "
                "Coba sebutkan bahan yang kamu punya, ya!"
            ),
        }), 422

    if tfidf is None or tfidf_matrix is None or df_recipes is None:
        logger.warning("Model belum tersedia.")
        return jsonify({
            "success": False,
            "reply": "Layanan rekomendasi belum siap. Silakan coba beberapa saat lagi.",
        }), 503

    try:
        recommendations = get_recommendations(query_model, top_n=5)
        return jsonify({
            "success": True,
            "query_used": query_model,
            "recommendations": recommendations,
        }), 200

    except Exception as e:
        logger.error(f"Error saat memproses rekomendasi: {e}")
        return jsonify({
            "success": False,
            "reply": "Terjadi kesalahan internal pada layanan rekomendasi.",
        }), 500


# ---------------------------------------------------------------------------
# Health Check
# ---------------------------------------------------------------------------
@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "model_loaded": tfidf is not None,
        "total_recipes": len(df_recipes) if df_recipes is not None else 0,
    }), 200

# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)