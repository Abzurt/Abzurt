from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import os
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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
        logger.info(f"FETCH: Starting scrape_links for {source_url}")
        start_time = time.time()
        response = requests.get(source_url, headers=headers, timeout=30)
        fetch_time = time.time() - start_time
        logger.info(f"FETCH: Request took {fetch_time:.2f}s for {source_url}")
        
        if response.status_code == 200:
            response.encoding = response.apparent_encoding
            parse_start = time.time()
            soup = BeautifulSoup(response.text, 'lxml')
            parse_time = time.time() - parse_start
            logger.info(f"FETCH: Parsing took {parse_time:.2f}s for {source_url}")
            
            links = []
            for a in soup.find_all('a', href=True):
                href = a['href']
                if len(href) < 5 or href.startswith(('#', 'javascript:')):
                    continue
                
                # Improved heuristic for news articles
                is_junk = any(word in href.lower() for word in ['facebook', 'twitter', 'instagram', 'linkedin', 'about', 'contact', 'privacy', 'terms', 'signup', 'login', 'reklam', 'kunye', 'bize-ulasin', 'cerez', 'politikasi'])
                if is_junk:
                    continue
                
                # Check path depth or common news patterns
                path = href.split('?')[0]
                depth = path.strip('/').count('/')
                
                # Heuristic: Articles usually have depth > 0 (not a main section) 
                # and either contain digits OR have significant slug length
                is_likely_article = (depth >= 1 and len(path) > 20) or \
                                   any(char.isdigit() for char in href) or \
                                   any(marker in href.lower() for marker in ['haber', 'detay', 'article', 'post', 'news', 'sx'])
                
                if is_likely_article:
                    full_url = urljoin(source_url, href)
                    if full_url not in links:
                        links.append(full_url)
                if len(links) >= 15: # Fetch more links to filter successfully later
                    break
            
            total_time = time.time() - start_time
            logger.info(f"FETCH: Total scrape_links took {total_time:.2f}s for {source_url}")
            return links
    except Exception as e:
        logger.error(f"Scrape Links Error: {e}")
    return []

def scrape_details(article_url, category):
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
        logger.info(f"DETAILS: Starting scrape_details for {article_url}")
        start_time = time.time()
        response = requests.get(article_url, headers=headers, timeout=30)
        fetch_time = time.time() - start_time
        
        if response.status_code == 200:
            response.encoding = response.apparent_encoding
            soup = BeautifulSoup(response.text, 'lxml')
            logger.info(f"DETAILS: Fetch+Parse took {time.time() - start_time:.2f}s")
            
            # Better title extraction
            title = get_meta(soup, 'og:title') or get_meta(soup, 'twitter:title')
            if not title or title.lower() in ['tr_tr', 'article', 'website']:
                title = soup.find('h1').get_text(strip=True) if soup.find('h1') else "Başlıksız"
            
            # Better content extraction
            content = get_meta(soup, 'og:description') or get_meta(soup, 'description') or get_meta(soup, 'twitter:description')
            if not content or content.lower() in ['tr_tr']:
                content = soup.find('p').get_text(strip=True) if soup.find('p') else "İçerik çekilemedi."
            
            image_url = get_meta(soup, 'og:image') or get_meta(soup, 'twitter:image') or ""
            
            return {
                "title": title.strip(),
                "content": content.strip()[:300] + ("..." if len(content.strip()) > 300 else ""),
                "imageUrl": image_url,
                "sourceUrl": article_url,
                "category": category
            }
    except Exception as e:
        logger.error(f"Scrape Details Error: {e}")
    return None

def get_meta(soup, property_name):
    meta = soup.find('meta', property=property_name) or soup.find('meta', attrs={"name": property_name})
    return meta['content'] if meta and meta.get('content') else None

if __name__ == '__main__':
    # Bind to PORT if provided by Render, else default to 5000
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
