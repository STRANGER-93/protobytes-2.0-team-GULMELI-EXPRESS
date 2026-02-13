import os
import re
import json

def scan_urls(project_root):
    endpoints = []
    
    # Regex patterns
    path_pattern = re.compile(r"path\s*\(\s*['\"]([^'\"]*)['\"]\s*,\s*([^,]+)")
    router_register_pattern = re.compile(r"router\.register\s*\(\s*r?['\"]([^'\"]+)['\"]\s*,\s*([^,]+)")
    api_view_pattern = re.compile(r"@api_view\s*\(\s*\[([^\]]*)\]")
    class_view_pattern = re.compile(r"class\s+(\w+)\s*\((.*?)\):")
    serializer_class_pattern = re.compile(r"serializer_class\s*=\s*(\w+)")
    permission_classes_pattern = re.compile(r"permission_classes\s*=\s*\[(.*?)\]")
    
    # Find all urls.py
    for root, dirs, files in os.walk(project_root):
        if "urls.py" in files:
            file_path = os.path.join(root, "urls.py")
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
                # Check for app_name or prefix based on folder structure?
                # Simplified: just grab paths
                
                # Scan paths
                for match in path_pattern.finditer(content):
                    route = match.group(1)
                    view_name = match.group(2).strip()
                    endpoints.append({
                        "path": route,
                        "view": view_name,
                        "source": file_path,
                        "type": "path"
                    })
                    
                # Scan routers
                for match in router_register_pattern.finditer(content):
                    route = match.group(1)
                    viewset_name = match.group(2).strip()
                    endpoints.append({
                        "path": route,
                        "view": viewset_name,
                        "source": file_path,
                        "type": "router"
                    })

    # Enrich with View details
    # This is a naive implementation; logic to map view names to files is complex to do statically
    # So we will just scan all views.py and index them
    views_metadata = {}
    for root, dirs, files in os.walk(project_root):
        if "views.py" in files:
            file_path = os.path.join(root, "views.py")
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
                # Scan classes
                for match in class_view_pattern.finditer(content):
                    class_name = match.group(1)
                    
                    # Look ahead for serializer_class and permissions
                    # This is limited to simple cases close to definition
                    # Using a simple sliding window or just searching the whole file for the class block would be better
                    # But for now, we just check if the class definition is followed by properties
                    
                    # We can't easily associate lines to class without a parser.
                    # Hack: just store that this class exists in this file
                    views_metadata[class_name] = {
                        "file": file_path,
                        "serializer": None,
                        "permissions": []
                    }

    # Second pass on views to find properties (very rough)
    for class_name, meta in views_metadata.items():
        try:
            with open(meta["file"], "r", encoding="utf-8") as f:
                lines = f.readlines()
            
            in_class = False
            for line in lines:
                if f"class {class_name}" in line:
                    in_class = True
                    continue
                if in_class and line.startswith("class "): # Next class
                    in_class = False
                
                if in_class:
                    if "serializer_class =" in line:
                        match = serializer_class_pattern.search(line)
                        if match: meta["serializer"] = match.group(1)
                    if "permission_classes =" in line:
                        match = permission_classes_pattern.search(line)
                        if match: meta["permissions"] = match.group(1).replace(" ", "").split(",")

        except Exception:
            pass

    # Merge
    final_endpoints = []
    for ep in endpoints:
        view_name = ep["view"].split(".as_view")[0] # clean as_view()
        if "." in view_name: view_name = view_name.split(".")[-1] # clean module.View
        
        meta = views_metadata.get(view_name, {})
        
        ep["serializer"] = meta.get("serializer")
        ep["permissions"] = meta.get("permissions")
        final_endpoints.append(ep)

    with open("api_audit.json", "w") as f:
        json.dump(final_endpoints, f, indent=4)

if __name__ == "__main__":
    scan_urls(".")
