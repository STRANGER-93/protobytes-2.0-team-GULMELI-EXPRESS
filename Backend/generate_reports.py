import json
import os
import uuid

def generate_reports():
    with open('api_audit.json', 'r') as f:
        data = json.load(f)

    # 1. Build Prefix Map
    # Map file_source -> prefix
    # We look for entries in 'jansewa\urls.py' (root) that include other urls
    
    prefix_map = {}
    # default root
    root_source = next((x['source'] for x in data if 'jansewa' in x['source'] and 'urls.py' in x['source']), None)
    
    if root_source:
        prefix_map[root_source] = ""

    # First pass: find includes in root
    known_includes = {} # module_path -> prefix
    
    for entry in data:
        if 'include' in entry['view']:
            # Extract module: include('apps.bookings.urls')
            # remove formatting
            clean = entry['view'].replace("include(", "").replace(")", "").replace("'", "").replace('"', "")
            # clean might differ depending on regex match, scan.py output was: "include('apps.users.urls'))"
            # so replace '))' too
            clean = clean.replace('))', '')
            
            prefix = entry['path']
            known_includes[clean] = prefix
            
    # Map module paths to file paths
    # We assume standard structure: apps.bookings.urls -> .\apps\bookings\urls.py
    # scan.py output source like: .\\apps\\bookings\\urls.py
    
    file_map = {}
    for module, prefix in known_includes.items():
        # Convert dots to slashes
        partial_path = module.replace(".", "\\") + ".py"
        # Find matching source in data
        for entry in data:
            if partial_path in entry['source']:
                file_map[entry['source']] = prefix
                break
    
    # 2. Process Endpoints
    final_endpoints = []
    
    for entry in data:
        if entry['type'] != 'path': continue # Skip routers for now or handle later if present
        if 'include' in entry['view']: continue # Skip include entries themselves
        if 'admin' in entry['source'] or 'rest_framework' in entry['source']: continue # Skip admin/auth built-ins if desired, or keep
        
        # Get prefix
        prefix = file_map.get(entry['source'], "")
        
        # Clean path
        path = entry['path']
        full_url = f"http://127.0.0.1:8000/{prefix}{path}"
        
        # Method deduction (naive)
        methods = ["GET"]
        if "create" in entry['view'].lower() or "register" in entry['view'].lower(): methods = ["POST"]
        if "update" in entry['view'].lower(): methods = ["PUT", "PATCH"]
        if "destroy" in entry['view'].lower() or "delete" in entry['view'].lower(): methods = ["DELETE"]
        if "detail" in entry['view'].lower(): methods = ["GET"]
        if "list" in entry['view'].lower(): methods = ["GET"]
        
        # Explicit views might have standard methods
        if "APIView" in entry['view']: methods = ["GET", "POST"] # Fallback
        
        final_endpoints.append({
            "method": ", ".join(methods),
            "url": full_url,
            "auth": "JWT" if "IsAuthenticated" in (entry['permissions'] or []) else "None",
            "permissions": entry['permissions'],
            "serializer": entry['serializer'],
            "view": entry['view']
        })

    # 3. Generate Markdown Table
    md_lines = ["| METHOD | FULL URL | AUTH REQUIRED | SERIALIZER | PERMISSIONS |",
                "|---|---|---|---|---|"]
    
    for ep in final_endpoints:
        perms = ", ".join(ep['permissions']) if ep['permissions'] else "None"
        ser = ep['serializer'] if ep['serializer'] else "-"
        md_lines.append(f"| {ep['method']} | {ep['url']} | {ep['auth']} | {ser} | {perms} |")
        
    with open("endpoint_report.md", "w") as f:
        f.write("\n".join(md_lines))

    # 4. Generate Postman Collection
    postman_items = []
    for ep in final_endpoints:
        # Basic parsing of URL for Postman
        # http://127.0.0.1:8000/api/v1/bookings/
        # host: ["http://127.0.0.1:8000"]
        # path: ["api", "v1", "bookings", ""]
        
        # cleaning <int:pk> to :pk for Postman or {{pk}}
        clean_url = ep['url'].replace("<int:", ":").replace("<str:", ":").replace("<path:", ":").replace(">", "")
        
        item = {
            "name": f"{ep['method']} {clean_url}",
            "request": {
                "method": ep['method'].split(", ")[0], # Pick first
                "header": [{"key": "Authorization", "value": "Bearer {{token}}", "type": "text"}] if ep['auth'] == "JWT" else [],
                "url": {
                    "raw": clean_url,
                    "protocol": "http",
                    "host": ["127.0.0.1"],
                    "port": "8000",
                    "path": clean_url.replace("http://127.0.0.1:8000/", "").split("/")
                }
            },
            "response": []
        }
        postman_items.append(item)

    collection = {
        "info": {
            "name": "JanSewa API Audit",
            "description": "Auto-generated API collection from static analysis.",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
        },
        "item": postman_items
    }
    
    with open("postman_collection.json", "w") as f:
        json.dump(collection, f, indent=4)

if __name__ == "__main__":
    generate_reports()
