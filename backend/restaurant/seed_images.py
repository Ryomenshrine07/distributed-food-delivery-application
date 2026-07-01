#!/usr/bin/env python3
"""
Seed restaurant + menu-item images for the Jhansi demo data.

Pipeline:
  1. Read Cloudinary creds from src/main/resources/application.properties
     (the ${ENV:default} default values) -- nothing is hard-coded.
  2. Resolve a real, freely-licensed photo for each "concept" from the
     Wikipedia REST summary API (originalimage / thumbnail).
  3. Upload each photo into THIS account's Cloudinary via a signed
     upload-from-URL (so the assets live in the user's media library).
  4. Read the actual restaurant / menu_item rows from Postgres (via psql),
     map each row to a concept, and write + apply UPDATE statements.

Idempotent: Cloudinary public_ids are deterministic (overwrite=true) and the
SQL just re-sets image_url, so it is safe to re-run.
"""
import hashlib
import json
import os
import re
import base64
import subprocess
import sys
import time
import urllib.parse
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
PROPS = os.path.join(HERE, "src", "main", "resources", "application.properties")
SQL_OUT = os.path.join(HERE, "seed_images.sql")
DB = ["psql", "-U", "ryomen07", "-d", "restaurant_db"]
UA = {"User-Agent": "jhansi-demo-seeder/1.0 (local dev; contact: dev@example.com)"}
# upload.wikimedia.org rejects non-browser agents on its image CDN (403),
# so byte downloads use a browser UA.
BROWSER_UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                            "AppleWebKit/537.36 (KHTML, like Gecko) "
                            "Chrome/124.0 Safari/537.36"}
SEP = "\x1f"  # unit separator, safe against commas in names


# ---------------------------------------------------------------- creds
def read_creds():
    txt = open(PROPS, encoding="utf-8").read()

    def grab(key):
        m = re.search(r"%s=\$\{[^:}]+:([^}]+)\}" % re.escape(key), txt)
        if not m:
            m = re.search(r"%s=([^\s#]+)" % re.escape(key), txt)
        return m.group(1).strip() if m else None

    return {
        "cloud": grab("cloudinary.cloud-name"),
        "key": grab("cloudinary.api-key"),
        "secret": grab("cloudinary.api-secret"),
    }


# ---------------------------------------------------------------- wikipedia
def wiki_image(titles):
    for title in titles:
        try:
            url = "https://en.wikipedia.org/api/rest_v1/page/summary/" + \
                  urllib.parse.quote(title.replace(" ", "_"))
            req = urllib.request.Request(url, headers=UA)
            data = json.load(urllib.request.urlopen(req, timeout=25))
            # Prefer the thumbnail (small) upscaled to a sane width -- the full
            # originalimage is often >25MP and Cloudinary rejects it with HTTP 400.
            thumb = (data.get("thumbnail") or {}).get("source")
            orig = (data.get("originalimage") or {}).get("source")
            src = thumb or orig
            if src and not src.lower().endswith(".svg"):
                # Use the thumbnail URL exactly as returned. Wikimedia only
                # serves a fixed set of thumbnail widths and rejects arbitrary
                # ones (HTTP 400 "use thumbnail sizes listed ..."), so we must
                # NOT rewrite the width.
                return src
        except Exception as e:  # noqa
            print(f"      wiki miss '{title}': {e}")
        time.sleep(0.2)
    return None


# ---------------------------------------------------------------- cloudinary
def fetch_bytes(url, retries=3):
    """Download image bytes ourselves (proper UA) so Cloudinary never has to
    fetch from Wikimedia (which rate-limits/blocks server-side fetchers)."""
    last = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=BROWSER_UA)
            with urllib.request.urlopen(req, timeout=40) as r:
                ctype = r.headers.get("Content-Type", "image/jpeg").split(";")[0]
                return ctype, r.read()
        except Exception as e:  # noqa
            last = e
            time.sleep(1 + attempt)
    raise last


def cloud_upload(creds, public_id, remote_url):
    ctype, data = fetch_bytes(remote_url)
    if not ctype.startswith("image/"):
        ctype = "image/jpeg"
    file_uri = "data:%s;base64,%s" % (ctype, base64.b64encode(data).decode())

    ts = str(int(time.time()))
    to_sign = f"overwrite=true&public_id={public_id}&timestamp={ts}"
    sig = hashlib.sha1((to_sign + creds["secret"]).encode()).hexdigest()
    body = urllib.parse.urlencode({
        "file": file_uri,
        "api_key": creds["key"],
        "timestamp": ts,
        "public_id": public_id,
        "overwrite": "true",
        "signature": sig,
    }).encode()
    endpoint = f"https://api.cloudinary.com/v1_1/{creds['cloud']}/image/upload"
    req = urllib.request.Request(endpoint, data=body, headers=UA)
    try:
        resp = json.load(urllib.request.urlopen(req, timeout=90))
        return resp["secure_url"]
    except urllib.error.HTTPError as e:
        detail = e.read().decode(errors="replace")[:300]
        raise RuntimeError(f"{e.code} {detail}")


# ---------------------------------------------------------------- concepts
# concept key -> ordered candidate Wikipedia titles (first hit wins)
CONCEPTS = {
    "butter_chicken": ["Butter chicken"],
    "chicken_tikka": ["Chicken tikka", "Tandoori chicken"],
    "paneer_tikka": ["Paneer tikka"],
    "spring_roll": ["Spring roll"],
    "dal_makhani": ["Dal makhani", "Dal"],
    "paneer_makhani": ["Paneer makhani", "Shahi paneer"],
    "naan": ["Naan"],
    "pizza_margherita": ["Pizza Margherita", "Margherita pizza"],
    "pizza": ["Pizza"],
    "garlic_bread": ["Garlic bread"],
    "choco_lava": ["Molten chocolate cake", "Chocolate cake"],
    "shahi_paneer": ["Shahi paneer", "Paneer makhani"],
    "kofta": ["Kofta"],
    "mix_veg": ["Navratan korma", "Curry"],
    "roti": ["Roti", "Chapati"],
    "biryani": ["Biryani"],
    "jeera_rice": ["Pilaf", "Cooked rice", "Rice"],
    "hakka_noodles": ["Hakka noodles", "Chow mein", "Lo mein"],
    "chilli_paneer": ["Chilli paneer", "Paneer"],
    "manchurian": ["Manchurian (dish)", "Gobi manchurian"],
    "samosa": ["Samosa"],
    "veg_burger": ["Veggie burger", "Hamburger"],
    "cold_coffee": ["Iced coffee", "Cold brew coffee"],
    "thali": ["Thali"],
    "chole_bhature": ["Chole bhature", "Chana masala"],
    "rajma": ["Rajma", "Rajma chawal"],
    "masala_dosa": ["Masala dosa", "Dosa"],
    "idli": ["Idli", "Idli sambar"],
    "dosa": ["Dosa", "Masala dosa"],
    "french_fries": ["French fries"],
    "cheese_burger": ["Cheeseburger", "Hamburger"],
    "chicken_burger": ["Chicken sandwich", "Hamburger"],
    "milkshake": ["Milkshake"],
    # restaurant covers
    "cover_north_indian": ["North Indian cuisine", "Punjabi cuisine", "Thali"],
    "cover_pizza": ["Pizza"],
    "cover_chinese": ["Chinese cuisine", "American Chinese cuisine", "Hakka noodles"],
    "cover_cafe": ["Coffeehouse", "Cafe"],
    "cover_pure_veg": ["Vegetarian cuisine", "Indian cuisine", "Thali"],
}

ITEM_CONCEPT = {
    "Paneer Tikka": "paneer_tikka", "Chicken Tikka": "chicken_tikka",
    "Veg Spring Roll": "spring_roll", "Butter Chicken": "butter_chicken",
    "Dal Makhani": "dal_makhani", "Paneer Butter Masala": "paneer_makhani",
    "Butter Naan": "naan", "Margherita Pizza": "pizza_margherita",
    "Veggie Supreme Pizza": "pizza", "Chicken Supreme Pizza": "pizza",
    "Garlic Bread": "garlic_bread", "Choco Lava Cake": "choco_lava",
    "Shahi Paneer": "shahi_paneer", "Veg Kofta": "kofta", "Mix Veg": "mix_veg",
    "Tandoori Roti": "roti", "Veg Biryani": "biryani", "Jeera Rice": "jeera_rice",
    "Veg Hakka Noodles": "hakka_noodles", "Chilli Paneer": "chilli_paneer",
    "Chicken Manchurian": "manchurian", "Samosa": "samosa", "Veg Burger": "veg_burger",
    "Cold Coffee": "cold_coffee", "Special Veg Thali": "thali",
    "Chole Bhature": "chole_bhature", "Rajma Chawal": "rajma",
    "Masala Dosa": "masala_dosa", "Idli Sambar": "idli", "Paneer Dosa": "dosa",
    "Paneer Tikka Pizza": "pizza", "Peri Peri Fries": "french_fries",
    "Veg Cheese Burger": "cheese_burger", "Chicken Burger": "chicken_burger",
    "Oreo Shake": "milkshake",
}

RESTAURANT_COVER = {
    "UP93 Restro and Lounge": "cover_north_indian",
    "Pizza Hut": "cover_pizza",
    "City Spicee": "cover_north_indian",
    "The Indian Spice Cafe and Restaurant": "cover_chinese",
    "The Flying Saucer Cafe": "cover_cafe",
    "Vrindavan Restaurant": "cover_pure_veg",
    "Domino's": "cover_pizza",
}

KEYWORDS = [
    ("pizza", "pizza"), ("burger", "veg_burger"), ("paneer", "paneer_makhani"),
    ("dosa", "dosa"), ("idli", "idli"), ("biryani", "biryani"), ("rice", "biryani"),
    ("noodle", "hakka_noodles"), ("manchurian", "manchurian"), ("coffee", "cold_coffee"),
    ("shake", "milkshake"), ("lava", "choco_lava"), ("cake", "choco_lava"),
    ("fries", "french_fries"), ("naan", "naan"), ("roti", "roti"), ("dal", "dal_makhani"),
    ("samosa", "samosa"), ("thali", "thali"), ("tikka", "paneer_tikka"),
    ("chicken", "butter_chicken"), ("veg", "mix_veg"),
]


def concept_for_item(name):
    if name in ITEM_CONCEPT:
        return ITEM_CONCEPT[name]
    low = name.lower()
    for kw, key in KEYWORDS:
        if kw in low:
            return key
    return None


def psql_rows(query):
    out = subprocess.run(
        DB + ["-t", "-A", "-F", SEP, "-c", query],
        capture_output=True, text=True, check=True).stdout
    rows = []
    for line in out.splitlines():
        if line.strip():
            rows.append(line.split(SEP))
    return rows


def sql_str(v):
    return "'" + v.replace("'", "''") + "'"


def main():
    creds = read_creds()
    if not all(creds.values()):
        print("ERROR: could not parse Cloudinary creds from", PROPS)
        sys.exit(1)
    print("Cloudinary cloud:", creds["cloud"], "(api key/secret loaded, not shown)")

    # 1. which concepts do we actually need?
    needed = set(RESTAURANT_COVER.values())
    items = psql_rows(
        "SELECT m.id, m.name FROM menu_items m "
        "JOIN menu_categories c ON c.id=m.category_id "
        "JOIN restaurants r ON r.id=c.restaurant_id WHERE r.deleted=false;")
    restaurants = psql_rows("SELECT id, name FROM restaurants WHERE deleted=false;")
    for _id, nm in items:
        k = concept_for_item(nm)
        if k:
            needed.add(k)

    # 2 + 3. resolve + upload each needed concept
    url_map = {}
    print(f"\nResolving + uploading {len(needed)} images to Cloudinary...")
    for key in sorted(needed):
        src = wiki_image(CONCEPTS.get(key, [key.replace('_', ' ')]))
        if not src:
            print(f"  [MISS] {key}: no source image")
            continue
        try:
            secure = cloud_upload(creds, f"jhansi_seed/{key}", src)
            url_map[key] = secure
            print(f"  [ok]   {key}")
        except Exception as e:  # noqa
            print(f"  [FAIL] {key}: {e}")

    # 4. build SQL
    lines = ["-- Auto-generated image assignments (Cloudinary URLs).", "BEGIN;"]
    miss_items = []
    for _id, nm in items:
        key = concept_for_item(nm)
        url = url_map.get(key) if key else None
        if url:
            lines.append(
                f"UPDATE menu_items SET image_url={sql_str(url)} WHERE id='{_id}';")
        else:
            miss_items.append(nm)
    for _id, nm in restaurants:
        key = RESTAURANT_COVER.get(nm, "cover_north_indian")
        url = url_map.get(key)
        if url:
            lines.append(
                "UPDATE restaurants SET image_url={u}, cover_image_url={u} "
                "WHERE id='{i}';".format(u=sql_str(url), i=_id))
    lines.append("COMMIT;")
    open(SQL_OUT, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print(f"\nWrote {SQL_OUT}")
    print(f"items updated: {len(items) - len(miss_items)} / {len(items)}"
          + (f"  | unmapped: {miss_items}" if miss_items else ""))

    # 5. apply
    res = subprocess.run(DB + ["-v", "ON_ERROR_STOP=1", "-f", SQL_OUT],
                         capture_output=True, text=True)
    sys.stdout.write(res.stdout)
    sys.stderr.write(res.stderr)
    if res.returncode != 0:
        sys.exit(res.returncode)
    print("\nDONE.")


if __name__ == "__main__":
    main()
