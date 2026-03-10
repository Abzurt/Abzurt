from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import os

app = Flask(__name__)
# Enable CORS for Flutter Web
CORS(app)

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

@app.route('/fetch', methods=['POST'])
def fetch_news():
    """
    API endpoint to fetch news article links and details.
    Expected JSON: {"action": "links" | "details", "url": "...", "category": "..."}
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No data provided"}), 400

        action = data.get("action")
        url = data.get("url")
        category = data.get("category", "Genel")

        if not url:
            return jsonify({"error": "URL is required"}), 400

        if action == "links":
            links = scrape_links(url)
            return jsonify({"links": links})
        
        elif action == "details":
            details = scrape_details(url, category)
            return jsonify({"details": details})
        
        return jsonify({"error": "Invalid action"}), 400

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def scrape_links(source_url):
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
        response = requests.get(source_url, headers=headers, timeout=10)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            links = []
            for a in soup.find_all('a', href=True):
                href = a['href']
                if len(href) < 5 or href.startswith(('#', 'javascript:')):
                    continue
                
                # Heuristic for news articles
                is_likely_article = any(char.isdigit() for char in href) or "SXHBQ" in href
                
                if is_likely_article:
                    full_url = urljoin(source_url, href)
                    if full_url not in links:
                        links.append(full_url)
                if len(links) >= 10:
                    break
            return links
    except Exception as e:
        print(f"Scrape Links Error: {e}")
    return []

def scrape_details(article_url, category):
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
        response = requests.get(article_url, headers=headers, timeout=10)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            title = get_meta(soup, 'og:title') or (soup.find('h1').get_text(strip=True) if soup.find('h1') else "Başlıksız")
            content = get_meta(soup, 'og:description') or get_meta(soup, 'description') or (soup.find('p').get_text(strip=True) if soup.find('p') else "İçerik çekilemedi.")
            image_url = get_meta(soup, 'og:image') or ""
            
            return {
                "title": title,
                "content": content,
                "imageUrl": image_url,
                "sourceUrl": article_url,
                "category": category
            }
    except Exception as e:
        print(f"Scrape Details Error: {e}")
    return None

def get_meta(soup, property_name):
    meta = soup.find('meta', property=property_name) or soup.find('meta', attrs={"name": property_name})
    return meta['content'] if meta and meta.get('content') else None

if __name__ == '__main__':
    # Bind to PORT if provided by Render, else default to 5000
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
