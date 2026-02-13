import os
import django
import json
import inspect
from django.conf import settings
from django.urls import URLPattern, URLResolver
from rest_framework.views import APIView
from rest_framework.viewsets import ViewSetMixin
from rest_framework.generics import GenericAPIView

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jansewa.settings')
django.setup()

def get_serializer_class(view, method):
    if hasattr(view, 'get_serializer_class'):
        try:
            return view.get_serializer_class().__name__
        except:
            pass
    if hasattr(view, 'serializer_class') and view.serializer_class:
        return view.serializer_class.__name__
    return None

def get_auth_classes(view):
    if hasattr(view, 'authentication_classes'):
        return [cls.__name__ for cls in view.authentication_classes]
    return []

def get_perm_classes(view):
    if hasattr(view, 'permission_classes'):
        return [cls.__name__ for cls in view.permission_classes]
    return []

def get_allowed_methods(view):
    if hasattr(view, 'allowed_methods'):
        return view.allowed_methods
    if hasattr(view, 'http_method_names'):
        return [m.upper() for m in view.http_method_names]
    return []

def extract_urls(urlpatterns, prefix=''):
    endpoints = []
    for pattern in urlpatterns:
        if isinstance(pattern, URLPattern):
            path = prefix + str(pattern.pattern)
            callback = pattern.callback
            
            # Handle class-based views
            if hasattr(callback, 'view_class'):
                view_class = callback.view_class
                view_instance = view_class()
                
                # Setup view instance for introspection
                view_instance.request = None
                
                methods = get_allowed_methods(view_instance)
                serializer = get_serializer_class(view_instance, 'GET') # Simplified
                auth = get_auth_classes(view_instance)
                perms = get_perm_classes(view_instance)
                
                endpoints.append({
                    'path': path,
                    'view': view_class.__name__,
                    'methods': methods,
                    'serializer': serializer,
                    'auth': auth,
                    'permissions': perms,
                    'type': 'ClassBasedView'
                })
            
            # Handle function-based views (DRF api_view decorator)
            elif hasattr(callback, 'cls'):
                view_class = callback.cls
                view_instance = view_class()
                
                methods = get_allowed_methods(view_instance)
                serializer = get_serializer_class(view_instance, 'GET')
                auth = get_auth_classes(view_instance)
                perms = get_perm_classes(view_instance)

                endpoints.append({
                    'path': path,
                    'view': callback.__name__,
                    'methods': methods,
                    'serializer': serializer,
                    'auth': auth,
                    'permissions': perms,
                    'type': 'FunctionBasedView'
                })
            else:
                # Regular Django view
                endpoints.append({
                    'path': path,
                    'view': callback.__name__,
                    'methods': ['GET', 'POST'], # Assumption
                    'serializer': None,
                    'auth': [],
                    'permissions': [],
                    'type': 'RegularView'
                })
                
        elif isinstance(pattern, URLResolver):
            new_prefix = prefix + str(pattern.pattern)
            endpoints.extend(extract_urls(pattern.url_patterns, new_prefix))
            
    return endpoints

if __name__ == '__main__':
    from django.core.management import execute_from_command_line
    from django.urls import get_resolver
    
    url_patterns = get_resolver().url_patterns
    all_endpoints = extract_urls(url_patterns)
    
    with open('api_audit.json', 'w') as f:
        json.dump(all_endpoints, f, indent=4)
        
    print(f"Introspection complete. Found {len(all_endpoints)} endpoints.")
