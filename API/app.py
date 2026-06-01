import pickle
import logging
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from sklearn.metrics.pairwise import cosine_similarity
 
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
    logger.info(f"Kolom df_recipes: {df_recipes.columns.tolist()}")
except FileNotFoundError:
    logger.warning("File model_cookcash.pkl tidak ditemukan.")
except Exception as e:
    logger.error(f"Gagal memuat model : {e}")


# ---------------------------------------------------------------------------
#  Rekomendasi
# ---------------------------------------------------------------------------
def check_allergy(ingredients_str: str, allergies: list) -> list:
    """
    Cek apakah string bahan mengandung salah satu item alergi.
    Return list alergi yang ditemukan (kosong = aman).
    """
    if not allergies:
        return []
    ingredients_lower = ingredients_str.lower()
    return [a for a in allergies if a.lower() in ingredients_lower]


def get_recommendations(query: str, allergies: list = None, top_n: int = 10) -> list:
    if allergies is None:
        allergies = []

    query_vec = tfidf.transform([query])
    scores = cosine_similarity(query_vec, tfidf_matrix).flatten()
 
    candidate_n = max(top_n * 4, 20)
    top_indices = scores.argsort()[::-1][:candidate_n]

    safe_results    = []
    allergy_results = []

    for idx in top_indices:
        row = df_recipes.iloc[idx]
        raw_steps = str(row.get("Steps", ""))
        steps_list = [
            s.strip()
            for s in raw_steps.replace("\\n", "\n").split("\n")
            if s.strip()
        ]
        ingredients_str = str(row.get("Ingredients Cleaned", ""))
        found_allergies = check_allergy(ingredients_str, allergies)

        recipe = {
            "id":                str(row.get("_id", row.name)),
            "title":             row["Title Cleaned"],
            "ingredients":       row["Ingredients Cleaned"],
            "steps":             steps_list,
            "total_steps":       int(row.get("Total Steps", len(steps_list))),
            "total_ingredients": int(row.get("Total Ingredients", 0)),
            "loves":             int(row.get("Loves", 0)),
            "category":          row["Category"],
            "score":             round(float(scores[idx]), 4),
            "has_allergy":       len(found_allergies) > 0,
            "allergy_found":     found_allergies,
        }

        if found_allergies:
            allergy_results.append(recipe)
        else:
            safe_results.append(recipe)

        if len(safe_results) >= top_n:
            break

    combined = safe_results[:top_n]
    if len(combined) < top_n:
        combined += allergy_results[: top_n - len(combined)]

    return combined


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
    allergies = data.get("allergies", [])

    if not isinstance(allergies, list):
        allergies = []
    allergies = [str(a).strip() for a in allergies if str(a).strip()]

    if isinstance(ingredients, str):
        ingredients = [i.strip() for i in ingredients.split(",") if i.strip()]
 
    ingredients_str = " ".join(ingredients).strip()
    query_model = " ".join(filter(None, [title, ingredients_str, category])).strip()

    logger.info(f"Query model: '{query_model}'")
 
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
        recommendations = get_recommendations(query_model, allergies=allergies, top_n=5)
        allergy_count = sum(1 for r in recommendations if r.get("has_allergy"))
        return jsonify({
            "success": True,
            "query_used": query_model,
            "recommendations": recommendations,
            "allergy_warning": allergy_count > 0,
            "allergy_count": allergy_count,
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