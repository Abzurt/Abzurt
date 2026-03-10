from firebase_functions import https_fn
from firebase_admin import initialize_app
import requests
from bs4 import BeautifulSoup
import json

initialize_app()

@https_fn.on_request()
def fetch_news(req: https_fn.Request) -> https_fn.Response:
    """
    Firebase Cloud Function to fetch news article links and details.
    Expected JSON body: {"action": "links" | "details", "url": "..."}
    """
    # Enable CORS
    if req.method == "OPTIONS":
        return https_fn.Response(status=204, headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "3600"
        })

    try:
        data = req.get_json()
        action = data.get("action")
        url = data.get("url")
        category = data.get("category", "Genel")

        if action == "links":
            links = scrape_links(url)
            return https_fn.Response(json.dumps({"links": links}), headers={"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"})
        
        elif action == "details":
            details = scrape_details(url, category)
            return https_fn.Response(json.dumps({"details": details}), headers={"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"})
        
        return https_fn.Response("Invalid action", status=400)

    except Exception as e:
        return https_fn.Response(str(e), status=500, headers={"Access-Control-Allow-Origin": "*"})

def scrape_links(source_url):
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(source_url, headers=headers, timeout=10)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            links = []
            for a in soup.find_all('a', href=True):
                href = a['href']
                if len(href) < 5 or href.startswith(('#', 'javascript:')):
                    continue
                
                # Basic heuristic for news links
                is_likely_article = any(char.isdigit() for char in href) or "SXHBQ" in href
                
                if is_likely_article:
                    full_url = normalize_url(href, source_url)
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
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(article_url, headers=headers, timeout=10)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            title = get_meta(soup, 'og:title') or soup.find('h1').get_text(strip=True) if soup.find('h1') else "Başlıksız"
            content = get_meta(soup, 'og:description') or get_meta(soup, 'description') or soup.find('p').get_text(strip=True) if soup.find('p') else "İçerik çekilemedi."
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

def normalize_url(href, base_url):
    from urllib.parse import urljoin
    return urljoin(base_url, href)

def get_meta(soup, property_name):
    meta = soup.find('meta', property=property_name) or soup.find('meta', attrs={"name": property_name})
    return meta['content'] if meta and meta.get('content') else None
