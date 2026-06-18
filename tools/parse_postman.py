import json

def parse_postman(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    def extract_endpoints(items, level=2):
        output = ""
        for item in items:
            if "item" in item:
                output += f"{'#' * level} {item['name']}\n\n"
                output += extract_endpoints(item["item"], level + 1)
            else:
                req = item.get("request", {})
                method = req.get("method", "GET")
                url = req.get("url", {})
                if type(url) is dict:
                    url = url.get("raw", "")
                elif type(url) is str:
                    pass
                else:
                    url = ""
                
                # Replace postman vars
                url = url.replace("{{baseUrl}}", "http://morourak.runasp.net/api/v1")
                
                desc = req.get("description", "")
                output += f"### {method} {url}\n\n"
                output += f"**Name:** {item.get('name', '')}\n\n"
                if desc:
                    output += f"{desc}\n\n"
                body = req.get("body", {})
                if "raw" in body:
                    output += f"**Body (raw):**\n```json\n{body['raw']}\n```\n\n"
                if "formdata" in body:
                    output += f"**Body (form-data):**\n"
                    for form in body["formdata"]:
                        output += f"- `{form['key']}`: {form.get('type', 'text')} (value: {form.get('value', form.get('src', ''))})\n"
                    output += "\n"
        return output

    md = extract_endpoints(data.get("item", []), 2)
    with open("morourak_api_docs_updated.md", "w", encoding="utf-8") as f:
        f.write("# Morourak API Documentation\n\n" + data.get("info", {}).get("description", "") + "\n\n" + md)

if __name__ == "__main__":
    parse_postman("Api/Morourak.postman_collection_last.json")
